---
type: Runbook
title: SSH access from Windows and WSL2
description: How the ssh pgx alias is set up on both the Windows side and inside WSL2.
tags: [ssh, wsl, windows]
timestamp: 2026-10-19T02:30:00Z
---

# SSH access from Windows and WSL2

The key pair `id_ed25519_pgx` was generated on Windows and its public key added to the machine's
`~/.ssh/authorized_keys`.

## Windows (`%USERPROFILE%\.ssh\config`)

```
Host pgx
    HostName <hostname>.local
    HostKeyAlias <machine-ip>
    User <user>
    IdentityFile ~/.ssh/id_ed25519_pgx
```

`HostKeyAlias` is there because `known_hosts` had been populated by IP. Connecting by the mDNS name
then failed with `Host key verification failed.` Aliasing to the IP entry reuses the already-trusted
key and keeps working if DHCP hands out a new address.

## WSL2 (`~/.ssh/config`)

```
Host pgx
    HostName <machine-ip>
    User <user>
    IdentityFile ~/.ssh/id_ed25519_pgx
```

- WSL2 has no mDNS, so `.local` names do not resolve: use the IP, and update it if DHCP changes it
  (or reserve the address on the router).
- The key was copied from Windows into `~/.ssh/` with mode 600, and the host key entries from the
  Windows `known_hosts` were appended to the WSL one.
- Earlier, WSL2 in NAT mode could not reach the machine at all and every command went through
  `powershell.exe -Command 'ssh ...'`. When piping scripts that way, `tr -d "\r"` broke inside
  PowerShell quoting; the reliable form was `ssh pgx "echo $(base64 -w0 script.sh) | base64 -d | bash"`.
