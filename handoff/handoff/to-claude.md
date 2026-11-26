# Handoff to Claude Code - Dummy Git

## Where this came from

Subhash (owner, github.com/subhash-kashyap) asked for this on Nov 27, 2026
(~03:07 IST, WhatsApp voice note to Instinct). His words, paraphrased: swapping
between his personal and work GitHub accounts is extremely annoying; he wants
to **select a profile and activate it**, with configuration as a one-time step
and activation as close to one click as possible. He named it himself: "Dummy
Git". Keep the name. Keep the product simple - simplicity is the feature.

Repo: github.com/aiofsubhash/dummy-git (public). Subhash is a collaborator;
aiofsubhash is Instinct's own GitHub account. Instinct (this author) built v1.

## Design decisions (don't regress these)

1. **Commit identity and authentication are switched separately and both are
   switched.** `user.name`/`user.email` alone is cosmetic - pushes still go
   through whatever account is authenticated. Every activation sets the git
   identity AND flips auth (gh account or SSH key).
2. **SSH auth uses `core.sshCommand`, not `~/.ssh/config` host aliases.** One
   global setting, no per-repo remote rewrites, easy to unset. dummygit records
   what it set in `~/.dummygit/ssh-command` and only ever unsets a value it set
   itself - never clobber a hand-configured `core.sshCommand`.
3. **gh auth uses `gh auth switch --user`, plus one-time `gh auth setup-git`.**
   Requires both accounts logged in via `gh auth login` beforehand; the tool
   says so when that is missing instead of failing weirdly.
4. **Single dependency-free bash file.** No python, no node, no brew formula.
   Profiles are plain KEY=VALUE files in `~/.dummygit/profiles/` (written with
   printf %q, sourced back - keep that quoting intact).
5. **Global switching, not per-repo.** Deliberate for v1: matches how Subhash
   described the pain ("get into work GitHub mode, later get into personal
   mode"). Per-repo is listed as a next step, not a silent behavior change.

## What is tested (by Instinct, in a sandbox HOME, Nov 27 2026)

- `add` for both auth paths (SSH key with generation, gh account), via piped stdin
- `use` switches user.name/user.email; sets and later cleanly unsets
  `core.sshCommand` when moving from an SSH profile to a gh profile
- `use` does NOT unset a hand-set `core.sshCommand` that dummygit didn't write
- interactive no-arg picker (`dummygit` then a number) activates the right profile
- `list` marks the active profile; `remove` deletes it and clears `active`
- real `git commit` in a scratch repo picks up the switched author identity
- error paths: unknown profile, bad profile name, missing SSH key

Not tested: real `gh auth switch` between two live GitHub accounts (needs two
logged-in accounts on a real machine), Windows/Git Bash, zsh interaction
(the script is bash-only; that is fine - it runs under bash regardless of
login shell).

## Next steps Subhash may ask for (in likely order)

1. Per-repo profiles: `dummygit use work --here` writing to the repo's local
   config instead of `--global`.
2. `dummygit add` non-interactive flags for scripting.
3. Shell completions (bash/zsh/fish).
4. Windows native support (PowerShell port or confirm Git Bash works).
5. `brew`/`apt` packaging if he wants to share it publicly.

## Working agreement

- Work on a branch, open a PR, don't push straight to main.
- Public repo: no secrets, no emails beyond what Subhash already publishes,
  no machine-specific paths in committed files.
- Keep the README's "two layers" explanation - it is the part that makes
  people understand why the tool exists.
