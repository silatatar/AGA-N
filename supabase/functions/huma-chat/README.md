# huma-chat

Deploy with Supabase CLI after setting server-only secrets:

- `HUMA_MODEL_ENDPOINT`
- `HUMA_MODEL_API_KEY`

`SUPABASE_URL` and `SUPABASE_ANON_KEY` are supplied by Supabase. The function
requires a valid user bearer token, reconstructs policy server-side, bounds all
context, rejects malformed output, and never returns raw provider errors.

Without both model values the truthful result is `providerUnavailable`.
