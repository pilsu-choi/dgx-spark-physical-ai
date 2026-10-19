---
type: Lesson
title: Archive before deleting
description: The old build was deleted when the user wanted it archived; destructive steps need an explicit confirmation.
tags: [process, lesson]
timestamp: 2026-10-19T02:30:00Z
---

# Archive before deleting

The user said the old Isaac Sim on the SSD could be "wiped and reinstalled if needed". The agent
doing the setup read that as permission to delete, and removed `/mnt/ssd/isaac-sim` with `rm -rf` in
the same script that prepared the new layout. A few minutes later the user clarified they wanted the
x86 build **kept in a separate folder**. ext4 has no trash, and new files had already been written,
so recovery was not attempted. The user decided to go ahead with the fresh setup.

**Rule:** on a disk that is not yours, move to an `archive/` directory, never `rm`. Delete only after an
explicit "delete it" for that specific path. Keep destructive steps out of multi-step setup scripts.
