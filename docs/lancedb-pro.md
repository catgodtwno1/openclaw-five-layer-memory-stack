# LanceDB Pro

## Role

LanceDB Pro is the structured conversation memory layer.

## Responsibilities

- memory extraction from dialogue
- recall by scope/category/time
- plugin-based memory operations
- occupancy of `plugins.slots.memory`

## Coexistence constraint

Because LanceDB Pro declares `kind: "memory"`, it cannot share memory slot ownership with another `kind: "memory"` plugin.

That is why original Cognee conflicts with it.
