# Local Validation

This document tracks the validation stages for a single-machine deployment.

## Validation checklist

- [x] QMD installed and independently searchable
- [x] QMD configured as `memory.backend = "qmd"`
- [x] `openclaw memory status` reports `Provider: qmd`
- [x] LanceDB Pro loaded as memory plugin
- [x] Cognee sidecar loaded without memory slot conflict
- [x] lossless-claw loaded as contextEngine
- [x] MemOS service reachable and tested
- [ ] final in-session retrieval proof using real conversation path

## Important nuance

A shell command like:

```bash
openclaw memory search "query"
```

may be denied outside a real session context due to scope restrictions.

That does **not** necessarily mean QMD backend activation failed.

The stronger indicator is:

```bash
openclaw memory status
```

showing:

```text
Provider: qmd (requested: qmd)
```

## Result

The local stack is functionally integrated. Remaining work is mainly around final session-context validation and public documentation cleanup.
