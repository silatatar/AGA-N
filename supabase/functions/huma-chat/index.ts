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
const DAILY_LIMIT = 120;
const MINUTE_LIMIT = 12;
const DAY_MS = 86_400_000;
const MINUTE_MS = 60_000;

// Rate-limit counters and idempotency records live in public.huma_request_log
// (see supabase/migrations/202609140001_phase42_huma_request_log.sql), not in
// process memory: Deno Deploy isolates are short-lived and multi-instance, so
// an in-memory Map silently resets and gives every new isolate its own empty
// counters and idempotency cache. All access goes through PostgREST using the
// caller's own bearer token so RLS (auth.uid() = user_id) is the only access
// control -- this function never holds a service-role key.
class RequestLogStore {
  constructor(private supabaseUrl: string, private publicKey: string, private userToken: string) {}

  private async rest(path: string, init: RequestInit = {}): Promise<Response> {
    return await fetch(`${this.supabaseUrl}/rest/v1/${path}`, {
      ...init,
      headers: {
        "content-type": "application/json",
        apikey: this.publicKey,
        authorization: `Bearer ${this.userToken}`,
        ...(init.headers ?? {}),
      },
      signal: AbortSignal.timeout(5_000),
    });
  }
  /** Returns the previously stored response for this idempotency key, if any. */
  async findCompleted(userId: string, idempotencyKey: string): Promise<Json | null> {
    const res = await this.rest(
      `huma_request_log?user_id=eq.${userId}&idempotency_key=eq.${encodeURIComponent(idempotencyKey)}&select=response&limit=1`,
    );
    if (!res.ok) throw new Error("request_log_read_failed");
    const rows = (await res.json()) as Array<{ response: Json }>;
    return rows[0]?.response ?? null;
  }

  /** Returns request timestamps (ms) recorded for this user in the last 24h. */
  async recentTimestamps(userId: string): Promise<number[]> {
    const since = new Date(Date.now() - DAY_MS).toISOString();
    const res = await this.rest(
      `huma_request_log?user_id=eq.${userId}&created_at=gte.${since}&select=created_at`,
    );
    if (!res.ok) throw new Error("request_log_read_failed");
    const rows = (await res.json()) as Array<{ created_at: string }>;
    return rows.map((r) => new Date(r.created_at).getTime());
  }

  /** Records a completed turn. Safe to call twice for the same key (upsert). */
  async record(userId: string, idempotencyKey: string, request: Json, response: Json): Promise<void> {
    const res = await this.rest(`huma_request_log?on_conflict=user_id,idempotency_key`, {
      method: "POST",
      headers: { Prefer: "resolution=merge-duplicates,return=minimal" },
      body: JSON.stringify({
        user_id: userId,
        idempotency_key: idempotencyKey,
        request_id: request.requestId,
        session_id: request.sessionId,
        turn_id: request.turnId,
        response,
      }),
    });
    if (!res.ok) throw new Error("request_log_write_failed");
  }
}
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
  const idempotencyKey = `${request.sessionId}:${request.requestId}:${request.turnId}`;
  const store = new RequestLogStore(supabaseUrl, publicKey, token);
  try {
    const prior = await store.findCompleted(user.id, idempotencyKey);
    if (prior) return reply(200, prior);
    const now = Date.now();
    const usage = await store.recentTimestamps(user.id);
    if (usage.length >= DAILY_LIMIT || usage.filter((time) => now - time < MINUTE_MS).length >= MINUTE_LIMIT) {
      return reply(429, { error: "rateLimited" });
    }
  } catch {
    console.log(JSON.stringify({ event: "huma_request_failed", requestId: request.requestId, failure: "request_log" }));
    return reply(503, { error: "providerUnavailable" });
  }
  const endpoint = Deno.env.get("HUMA_MODEL_ENDPOINT");
  const providerKey = Deno.env.get("HUMA_MODEL_API_KEY");
  if (!endpoint || !providerKey) return reply(503, { error: "providerUnavailable" });
  try {
    const provider: HumaModelProvider = new ConfiguredHttpModelProvider(endpoint, providerKey);
    const raw = await provider.generate(policyFor(request), request);
    const safe = validateOutput(raw, request);
    if (!safe) return reply(502, { error: "malformedResponse" });
    await store.record(user.id, idempotencyKey, request, safe);
    console.log(JSON.stringify({ event: "huma_request_succeeded", requestId: request.requestId, sessionId: request.sessionId }));
    return reply(200, safe);
  } catch {
    console.log(JSON.stringify({ event: "huma_request_failed", requestId: request.requestId, failure: "provider" }));
    return reply(503, { error: "providerUnavailable" });
  }
});
