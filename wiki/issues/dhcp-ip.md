---
type: Issue
title: Machine IP comes from DHCP
description: The WSL2 ssh config uses a raw IP that can change.
tags: [ssh, network]
timestamp: 2026-10-19T02:30:00Z
---

# Machine IP comes from DHCP

WSL2 cannot resolve `.local` names, so its `ssh pgx` entry uses the IP. If the router assigns a new
address, WSL access breaks until `HostName` is updated. The Windows entry uses the mDNS name plus
`HostKeyAlias` and keeps working.

**Fix:** reserve the address for the machine's MAC on the router, or enable WSL mirrored networking
and mDNS.
