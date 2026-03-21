# Cognee Sidecar

## Why sidecar exists

Original Cognee integration was implemented as a memory plugin.
That causes a hard conflict with LanceDB Pro because both want the memory slot.

## Sidecar approach

The sidecar variant removes `kind: "memory"` and keeps the lifecycle/hooks-based behavior needed for:

- synchronization
- recall
- memory injection

## Key finding

Generic plugin hooks still work even when the plugin does not own the memory slot.

## Result

- LanceDB Pro keeps memory slot ownership
- Cognee sidecar still provides recall/sync behavior
- coexistence becomes practical
