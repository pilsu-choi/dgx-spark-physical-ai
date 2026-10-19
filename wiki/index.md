---
type: Index
title: dgx-spark-physical-ai wiki
description: Entry point: setting up Isaac Sim, Isaac Lab and Cosmos on a DGX Spark-class machine with storage on an external SSD.
tags: [index]
timestamp: 2026-10-19T02:30:00Z
---

# dgx-spark-physical-ai wiki

This wiki follows the Open Knowledge Format (OKF v0.1) used in my other projects: plain Markdown
files with YAML frontmatter, one concept per file, ordinary relative links. Each directory has an
`index.md`, and [log.md](log.md) holds the chronological history of the work.

Start with the [overview](overview.md).

| Section | What is there |
| --- | --- |
| [overview.md](overview.md) | Hardware, goal, scope, current status |
| [runbooks/](runbooks/index.md) | Step-by-step: SSH access, external SSD, Isaac Sim/Lab, Cosmos3-Nano |
| [decisions/](decisions/index.md) | Choices made and why |
| [lessons/](lessons/index.md) | Things that went wrong and what they taught |
| [research/](research/index.md) | What official docs and community reports say, checked against the machine |
| [issues/](issues/index.md) | Known gaps and open questions |
| [log.md](log.md) | Chronological work log |

## Conventions

- Every page has `type`, `title`, `description`, `tags` and `timestamp` (UTC, ISO 8601).
- Numbers marked *measured* come from runs on the machine; raw output is in [docs/logs](../docs/logs).
- No secrets, serial numbers, IP addresses or network names are recorded here.
