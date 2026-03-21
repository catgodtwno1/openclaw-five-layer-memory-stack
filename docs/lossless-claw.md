# lossless-claw

## Role

lossless-claw is the context compaction layer.

## Responsibilities

- preserve long chat history in summary DAG form
- store compaction results in SQLite
- provide LCM-based recall tools

## Slot

It occupies:

- `plugins.slots.contextEngine`

This is separate from the memory slot, which is why it can coexist with LanceDB Pro.
