const MAX_INPUT = 1200;
const MAX_OUTPUT = 1800;
const MAX_TURNS = 8;
const MAX_VOCABULARY = 8;
const RESPONSE_SCHEMA = "huma-response-v1";

type Json = Record<string, unknown>;

interface HumaModelProvider {
  generate(systemPolicy: string, payload: Json): Promise<Json>;
}

class ConfiguredHttpModelProvider implements HumaModelProvider {
  constructor(private endpoint: string, private apiKey: string) {}
  async generate(systemPolicy: string, payload: Json): Promise<Json> {
    const response = await fetch(this.endpoint, {
      method: "POST",
      headers: { "content-type": "application/json", authorization: `Bearer ${this.apiKey}` },
      body: JSON.stringify({ systemPolicy, input: payload, responseSchemaVersion: RESPONSE_SCHEMA }),
      signal: AbortSignal.timeout(10_000),
    });
    if (!response.ok) throw new Error("provider_failure");
    return await response.json();
  }
}

const usageByUser = new Map<string, number[]>();
const completed = new Map<string, Json>();

function reply(status: number, body: Json) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", "cache-control": "no-store" },
  });
}

function boundedStrings(value: unknown, max: number): string[] | null {
  if (!Array.isArray(value) || value.length > max || value.some((v) => typeof v !== "string")) return null;
  return value as string[];
}

function validateRequest(value: unknown): Json | null {
  if (!value || typeof value !== "object") return null;
  const v = value as Json;
  const required = ["requestId", "sessionId", "turnId", "learnerType", "englishLevel", "scenario", "userMessage", "requestedAction", "locale", "policyVersion", "promptVersion"];
  if (v.requestSchemaVersion !== "huma-request-v1" || v.responseSchemaVersion !== RESPONSE_SCHEMA) return null;
  if (required.some((key) => typeof v[key] !== "string" || !(v[key] as string).trim())) return null;
  if ((v.userMessage as string).length > MAX_INPUT) return null;
  if (!boundedStrings(v.activeLearningGoals, 12) || !boundedStrings(v.targetVocabulary, MAX_VOCABULARY)) return null;
  if (!Array.isArray(v.recentContext) || v.recentContext.length > MAX_TURNS) return null;
  if (v.recentContext.some((t) => !t || typeof t !== "object" || typeof t.text !== "string" || t.text.length > MAX_INPUT)) return null;
  return v;
}

function policyFor(request: Json): string {
  const learner = ["child", "teen", "adult"].includes(String(request.learnerType)) ? String(request.learnerType) : "adult";
  const level = ["A1", "A2", "B1", "B2", "C1", "C2"].includes(String(request.englishLevel).toUpperCase()) ? String(request.englishLevel).toUpperCase() : "A1";
  const childRule = learner === "child" ? "No off-platform contact, adult topics, unrestricted social exchange, or high-risk advice." : "No high-risk advice or off-platform contact.";
  return `You are Hüma, AGAIN's warm English learning guide. Learner=${learner}; CEFR=${level}; mode=${request.requestedAction}. ${childRule} Keep answers concise, educational, non-judgmental and within ${MAX_OUTPUT} characters. Return only the declared structured response schema. Never award XP, unlock content, or claim product state changes.`;
}

function validateOutput(raw: Json, request: Json): Json | null {
  if (raw.responseSchemaVersion !== RESPONSE_SCHEMA || raw.requestId !== request.requestId) return null;
  if (typeof raw.assistantText !== "string" || !raw.assistantText.trim() || raw.assistantText.length > MAX_OUTPUT) return null;
  if (raw.responseMode !== request.requestedAction || !["safe", "redirected", "needsSupport"].includes(String(raw.safetyEvent))) return null;
  if (!boundedStrings(raw.suggestedReplies ?? [], 4) || !boundedStrings(raw.vocabularySuggestions ?? [], 8)) return null;
  return raw;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return reply(405, { error: "methodNotAllowed" });
  const token = req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return reply(401, { error: "unauthenticated" });
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const publicKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !publicKey) return reply(503, { error: "providerUnavailable" });
  const userResponse = await fetch(`${supabaseUrl}/auth/v1/user`, { headers: { authorization: `Bearer ${token}`, apikey: publicKey } });
  if (!userResponse.ok) return reply(401, { error: "unauthenticated" });
  const user = await userResponse.json();
  if (typeof user.id !== "string") return reply(401, { error: "unauthenticated" });
  let request: Json | null;
  try { request = validateRequest(await req.json()); } catch { request = null; }
  if (!request) return reply(400, { error: "invalidRequest" });
  const idempotencyKey = `${user.id}:${request.sessionId}:${request.requestId}:${request.turnId}`;
  const prior = completed.get(idempotencyKey);
  if (prior) return reply(200, prior);
  const now = Date.now();
  const usage = (usageByUser.get(user.id) ?? []).filter((time) => now - time < 86_400_000);
  if (usage.length >= 120 || usage.filter((time) => now - time < 60_000).length >= 12) {
    return reply(429, { error: "rateLimited" });
  }
  usage.push(now); usageByUser.set(user.id, usage);
  const endpoint = Deno.env.get("HUMA_MODEL_ENDPOINT");
  const providerKey = Deno.env.get("HUMA_MODEL_API_KEY");
  if (!endpoint || !providerKey) return reply(503, { error: "providerUnavailable" });
  try {
    const provider: HumaModelProvider = new ConfiguredHttpModelProvider(endpoint, providerKey);
    const raw = await provider.generate(policyFor(request), request);
    const safe = validateOutput(raw, request);
    if (!safe) return reply(502, { error: "malformedResponse" });
    completed.set(idempotencyKey, safe);
    console.log(JSON.stringify({ event: "huma_request_succeeded", requestId: request.requestId, sessionId: request.sessionId }));
    return reply(200, safe);
  } catch {
    console.log(JSON.stringify({ event: "huma_request_failed", requestId: request.requestId, failure: "provider" }));
    return reply(503, { error: "providerUnavailable" });
  }
});
