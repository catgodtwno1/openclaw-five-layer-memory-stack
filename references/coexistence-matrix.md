# Coexistence Matrix

| Component | Owns slot? | Slot | Can coexist? | Notes |
|---|---|---|---|---|
| QMD | No | n/a | Yes | backend for file retrieval |
| LanceDB Pro | Yes | memory | Yes | structured memory owner |
| original Cognee | Yes | memory | No | conflicts with LanceDB Pro |
| Cognee Sidecar | No | n/a | Yes | hooks-based recall/sync |
| lossless-claw | Yes | contextEngine | Yes | independent from memory slot |
| MemOS | No | n/a | Yes | external service layer |
