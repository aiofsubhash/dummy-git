# Dummy Git

Switch between your GitHub profiles (personal, work, client, whatever) without
the pain. Configure each profile **once**. After that, switching is one click.

```
$ dummygit
```

opens

```
+--------------------------------------------------+
|  Activate which GitHub profile?                  |
|  +----------------------------------------------+|
|  |  personal                                    ||
|  |  work                                        ||
|  +----------------------------------------------+|
|                              [ Cancel ]  [ OK ]  |
+--------------------------------------------------+
```

Pick a profile, click OK, done:

```
Active profile: work
  commits as: Subhash Kashyap <subhash.kashyap@touchkin.com>
  pushes via: gh account subhash-work
```

(No desktop on the machine? It falls back to a terminal number picker.)

## Why not just `git config user.email`?

Because that only changes the *label* on your commits. There are two separate
things, and mixing them up is why profile switching feels broken:

1. **Commit identity** - the name/email stamped on each commit
   (`git config user.name` / `user.email`)
2. **Authentication** - how GitHub verifies you when you push (your GitHub CLI
   login, or your SSH key)

Changing only the first is cosmetic: your commits say "work" but you still push
as "personal" (or get permission denied). Dummy Git switches **both** every
time, and it warns you about config that can silently defeat the switch
(stale credential helpers, `~/.ssh/config` host blocks, repo-local overrides).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/aiofsubhash/dummy-git/main/install.sh | bash
```

Or manually: download [`dummygit`](./dummygit), put it somewhere on your `PATH`
(e.g. `~/.local/bin`), `chmod +x` it. It is a single bash script. No other
dependencies beyond `git`. For GitHub-CLI-based auth you also need
[`gh`](https://cli.github.com). The click-to-pick dialog uses whatever your
system already has: `osascript` (macOS), `zenity`/`kdialog` (Linux), or
PowerShell (Windows Git Bash).

## One-time setup per profile

```bash
dummygit add personal
dummygit add work
```

For each profile it asks for:

- **Git author name and email** (use the email GitHub associates with that account)
- **How that account authenticates**, one of:
  1. **GitHub CLI account** - it runs `gh auth switch` (plus `gh auth setup-git`
     so https pushes actually use it) when you activate. Log both accounts in
     once with `gh auth login` and dummygit flips between them.
  2. **A dedicated SSH key** - it sets `core.sshCommand` to that key when you
     activate. It can generate the key for you; you paste the public key into
     that GitHub account's settings once.
  3. **Skip** - only commit identity switches.

## Every time after that

```bash
dummygit            # click a profile, OK, done
dummygit use work   # or name it directly, no prompt
```

## Other commands

| Command | What it does |
| --- | --- |
| `dummygit pick` | Terminal number picker (no GUI) |
| `dummygit gui` | Force the click dialog (errors if none available) |
| `dummygit list` | Show profiles (`*` = active) |
| `dummygit status` | Current identity, SSH command, gh accounts |
| `dummygit doctor` | Check for config that can silently defeat a switch |
| `dummygit remove work` | Delete a profile (your git config stays as-is) |
| `dummygit help` | Help |

## What can still go wrong (dummygit warns, never silently rewrites)

- A non-gh `credential.helper` (like `store` or a keychain helper) can keep
  serving the *old* account's https credentials after `gh auth switch`.
- An `IdentityFile` under `Host github.com` in `~/.ssh/config` competes with
  per-profile SSH keys.
- A repo's **local** config (`user.email`, `core.sshCommand`, a remote URL with
  embedded credentials) beats the global switch for that repo.

Run `dummygit doctor` any time; activation also checks these and tells you the
exact fix.

## Notes and limits

- Profiles live in `~/.dummygit/profiles/`. Plain text; edit by hand if you like.
- dummygit only ever touches `core.sshCommand` values it set itself. Anything
  you configured by hand is left alone.
- Switching is global (your whole machine), not per-repo. Per-repo profiles are
  a possible next step.
- Tested on Linux bash (zenity GUI included). macOS (osascript) and Windows
  (PowerShell) dialogs are implemented but not yet tested on real machines.
