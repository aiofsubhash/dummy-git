# Handoff to Claude Code - Dummy Git

## Where this came from

Subhash (owner, github.com/subhash-kashyap) asked for this on Nov 27, 2026
(~03:07 IST, WhatsApp voice note to Instinct). His words, paraphrased: swapping
between his personal and work GitHub accounts is extremely annoying; he wants
to **select a profile and activate it**, with configuration as a one-time step
and activation as close to one click as possible. He named it himself: "Dummy
Git". Keep the name. Keep the product simple - simplicity is the feature.

Repo: github.com/aiofsubhash/dummy-git (public). Subhash is a collaborator;
aiofsubhash is Instinct's own GitHub account. Instinct (this author) built it; v0.3 came via PR #1 (instinct/blocking-guards), the first change to follow the branch+PR rule - v0.1/v0.2 went straight to main before the rule was applied here; that history stays as-is.

## Design decisions (don't regress these)

1. **Commit identity and authentication are switched separately and both are
   switched.** `user.name`/`user.email` alone is cosmetic - pushes still go
   through whatever account is authenticated. Every activation sets the git
   identity AND flips auth (gh account or SSH key).
2. **Activation must be a click.** Bare `dummygit` opens a GUI picker
   (osascript on macOS, zenity/kdialog on Linux, PowerShell on Windows Git
   Bash) and falls back to a terminal number picker when there is no display.
   `dummygit use <name>` stays for scripts. v0.1 was terminal-only; that did
   not meet the ask.
3. **A switch that would not take must not pretend to take.** Pre-flight
   guards BLOCK activation (exit 1, zero changes, profile not marked active)
   when existing config would defeat it: non-gh credential.helper, or an
   IdentityFile for github.com in ~/.ssh/config. Repo-local overrides cannot
   be "fixed" globally, so there the global switch completes but the tool
   prints NOT ACTIVE IN THIS REPO and exits 2. Warn-then-mark-active was the
   v0.2 behavior; it was wrong.
4. **SSH auth uses `core.sshCommand`, not `~/.ssh/config` host aliases.** One
   global setting, no per-repo remote rewrites, easy to unset. dummygit records
   what it set in `~/.dummygit/ssh-command` and only ever unsets a value it set
   itself - never clobber a hand-configured `core.sshCommand`.
5. **gh auth uses `gh auth switch --user` PLUS `gh auth setup-git`, and the
   README says so honestly: setup-git WRITES global git config (host-scoped
   credential helper for github.com). It is a deliberate global auth change,
   not a side effect to hide. Both accounts must be logged in (`gh auth login`
   once each); the tool says so instead of failing weirdly.
6. **Snapshot before changing.** Every activation that passes pre-flight
   writes ~/.dummygit/previous.conf (identity, core.sshCommand, active
   profile) first; `dummygit undo` restores it. Undo covers git config only -
   gh-side state is not reversed (documented). Pre-flight guards and undo
   never edit config dummygit does not own.
7. **Single dependency-free bash file.** Profiles are plain KEY=VALUE files in
   `~/.dummygit/profiles/` (written with printf %q, sourced back - keep that
   quoting intact). GUI tools are used only if already installed.
8. **Global switching, not per-repo.** Deliberate for v1: matches how Subhash
   described the pain ("get into work GitHub mode, later get into personal
   mode"). Per-repo is a listed next step, not a silent behavior change.

## Platform

His desktop OS is not on record. Circumstantial evidence points to macOS (he
built paceyouradhd.com as a Mac app and said it "excludes out windows users",
Sep 24 2026). The GUI covers macOS/Linux/Windows anyway. If he confirms one,
trim the README to lead with it.

## What is tested (by Instinct, sandbox HOME + xvfb, Nov 27 2026)

- `add` both auth paths (SSH key with real ssh-keygen generation, gh account)
- `use` switches user.name/user.email; sets and later cleanly unsets
  `core.sshCommand` moving SSH -> gh profile
- `use` does NOT unset a hand-set `core.sshCommand` that dummygit didn't write
- bare `dummygit`: opens the real zenity dialog under Xvfb; a scripted click
  (xdotool) on "work" + OK activated the work profile end to end; with no
  DISPLAY it falls back to the terminal picker
- BLOCKING (v0.3): credential.helper=store blocks a gh-profile activation -
  exit 1, git config byte-identical, profile not marked active; ssh-config
  IdentityFile blocks an ssh-profile activation the same way; repo-local
  override lets the global switch through but exits 2 and prints NOT ACTIVE
  IN THIS REPO
- undo (v0.3): after personal -> work, restores name/email/core.sshCommand and
  active profile; second undo errors cleanly; a contaminated-sequence trace
  was re-run clean to confirm exact restore values
- real `git commit` in a scratch repo picks up the switched author identity
- error paths: unknown profile, bad profile name, missing SSH key, `gui` with
  no dialog tool errors with the fallback hint

Not tested: real `gh auth switch` between two live GitHub accounts (needs his
machine with both logged in), the osascript dialog on a real Mac, the
PowerShell dialog on real Windows, zsh login-shell interaction (the script is
bash-only regardless).

## Next steps Subhash may ask for (in likely order)

1. Per-repo profiles: `dummygit use work --here` writing to the repo's local
   config instead of `--global`.
2. A persistent app shortcut (macOS .app / .desktop file) so he never opens a
   terminal at all.
3. `dummygit add` non-interactive flags for scripting.
4. Shell completions (bash/zsh/fish).
5. brew/apt packaging if he shares it publicly.

## Working agreement

- Work on a branch, open a PR, don't push straight to main.
- Public repo: no secrets, no emails beyond what Subhash already publishes,
  no machine-specific paths in committed files.
- Keep the README's "two layers" explanation - it is why the tool exists.
