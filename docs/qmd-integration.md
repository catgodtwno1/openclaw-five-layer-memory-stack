# QMD Integration

## Purpose

QMD replaces OpenClaw's builtin memory file search backend with a local-first retrieval engine.

## OpenClaw setting

```json
{
  "memory": {
    "backend": "qmd"
  }
}
```

## Why use it

- better retrieval than naive sqlite semantic search
- BM25 + vector + reranking
- local GGUF model downloads
- no cloud dependency required for baseline operation

## Important operational notes

- QMD CLI must be installed separately
- first embed/query may download local models
- OpenClaw manages QMD state inside its agent state directory
- direct CLI search may behave differently from in-session retrieval due to scope rules

## Example areas to index

- `memory/**/*.md`
- `docs/**/*.md`
- `skills/**/*.md`
- selected root markdown files
