# Dummy Git

Switch between your GitHub profiles (personal, work, client, whatever) without
the pain. Configure each profile **once**. After that, switching is one command.

```
$ dummygit
Which profile?
  1) * personal
  2)   work
Pick a number: 2
Active profile: work
  commits as: Subhash Kashyap <subhash.kashyap@touchkin.com>
  pushes via: SSH key /home/subhash/.ssh/id_ed25519_work
```

## Why not just `git config user.email`?

Because that only changes the *label* on your commits. There are two separate
things, and mixing them up is why profile switching feels broken:

1. **Commit identity** - the name/email stamped on each commit
   (`git config user.name` / `user.email`)
2. **Authentication** - how GitHub verifies you when you push (your GitHub CLI
   login, or your SSH key)

Changing only the first is cosmetic: your commits say "work" but you still push
as "personal" (or get permission denied). Dummy Git switches **both** every time.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/aiofsubhash/dummy-git/main/install.sh | bash
```

Or manually: download [`dummygit`](./dummygit), put it somewhere on your `PATH`
(e.g. `~/.local/bin`), `chmod +x` it. It is a single bash script. No other
dependencies beyond `git`. For GitHub-CLI-based auth you also need
[`gh`](https://cli.github.com).

## One-time setup per profile

```bash
dummygit add personal
dummygit add work
```

For each profile it asks for:

- **Git author name and email** (use the email GitHub associates with that account)
- **How that account authenticates**, one of:
  1. **GitHub CLI account** - it runs `gh auth switch` when you activate. Log
     both accounts in once with `gh auth login` and dummygit flips between them.
  2. **A dedicated SSH key** - it sets `core.sshCommand` to that key when you
     activate. It can generate the key for you; you paste the public key into
     that GitHub account's settings once.
  3. **Skip** - only commit identity switches.

## Every time after that

```bash
dummygit            # pick from a list, hit a number, done
dummygit use work   # or name it directly
```

## Other commands

| Command | What it does |
| --- | --- |
| `dummygit list` | Show profiles (`*` = active) |
| `dummygit status` | Current identity, SSH command, gh accounts |
| `dummygit remove work` | Delete a profile (your git config stays as-is) |
| `dummygit help` | Help |

## Notes and limits

- Profiles live in `~/.dummygit/profiles/`. It is plain text; you can edit by hand.
- dummygit only ever touches `core.sshCommand` values it set itself. Anything
  you configured by hand is left alone.
- Switching is global (your whole machine), not per-repo. Per-repo profiles are
  a possible next step.
- Tested on Linux/macOS bash. Windows: use Git Bash or WSL.
