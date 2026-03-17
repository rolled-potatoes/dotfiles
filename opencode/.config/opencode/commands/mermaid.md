---
description: Render a Mermaid diagram as ASCII art in the terminal. Pass the diagram source directly or describe what diagram you want drawn.
---

Render the following as a Mermaid diagram and display it as ASCII art in the terminal using the `render_mermaid` tool.

If the input already looks like Mermaid source code (starts with `flowchart`, `sequenceDiagram`, `classDiagram`, `pie`, `gantt`, `stateDiagram`, or `erDiagram`), pass it directly to `render_mermaid`.

Otherwise, generate appropriate Mermaid source code based on the description, then call `render_mermaid` with that code.

Input: $SELECTION
