# Rollback Notes

## If QMD backend causes issues

- set `memory.backend` back to the builtin/default backend
- restart the gateway
- confirm with `openclaw memory status`

## If Cognee sidecar causes issues

- disable sidecar entry
- optionally restore original Cognee fallback path
- keep LanceDB Pro as memory slot owner

## If lossless-claw causes issues

- restore previous `plugins.slots.contextEngine`
- restart gateway

## If MemOS is unavailable

- local stack should still work without MemOS
- treat MemOS as additive, not critical-path, unless explicitly designed otherwise
