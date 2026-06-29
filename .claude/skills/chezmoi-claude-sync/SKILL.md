---
description: Reconcile direct edits made to the live ~/.claude config back into the chezmoi source by reviewing each diff and selectively adopting only the intended changes (conflict resolution, not a blind sync). Use this whenever you (or the user) edited ~/.claude settings, skills, agents, hooks, or statusline directly instead of editing the chezmoi source, and `chezmoi status ~/.claude` shows drift — even if the user just says "sync my claude config", "I changed settings.json locally", "pull my local claude changes into chezmoi", or "resolve the chezmoi drift". Scope is strictly the files chezmoi already manages; it never brings new local files under management and never touches the live machine.
argument-hint: [optional path under ~/.claude]
---

# chezmoi ↔ ~/.claude reconcile (selective)

In this dotfiles repo the Claude Code config is managed by chezmoi: source
`dot_claude/` → target `~/.claude/`. The intended flow is *edit the source →
PR → `chezmoi apply` after merge*. In practice you sometimes edit the live
`~/.claude/` directly (tweaking `settings.json`, iterating on a skill), which
makes the target drift from the source.

This skill **reconciles that drift**. Unlike a blunt "add everything" sync, the
job here is to look at each diff, decide what is a deliberate change worth
keeping versus accidental noise, and bring **only the intended changes** back
into the source. Think of it as resolving a merge conflict between the live
machine and the tracked source — keep the good, drop the rest.

Two hard constraints shape everything below:

- **Managed-only scope.** Operate solely on paths chezmoi already tracks. Do not
  pull new, untracked files under management as a side effect — that is a
  separate, deliberate decision the user must ask for explicitly.
- **Never touch the live machine.** This skill only writes to the chezmoi
  *source* (and git). It must not run `chezmoi apply`. The repo's standing rule
  is that the live `~/.claude/` only changes via `chezmoi apply` *after a PR is
  merged*, so discarding unwanted local drift is reported, not executed here.

## Workflow

### 1. Preconditions

- Confirm chezmoi exists: `command -v chezmoi`.
- Resolve the source repo so git operations run in the right place:
  `SRC=$(chezmoi source-path)`. All commits/branches happen under `$SRC`.

### 2. Detect drift (managed files only)

```bash
chezmoi status ~/.claude   # one line per changed managed entry
chezmoi diff ~/.claude     # the actual content diff
```

`chezmoi status` shows two status columns. The second column (the actual state
vs. source) is what matters here: `M` = modified, `A` = added in target but
missing from source, `D` = present in source but deleted from target. If both
commands are empty, report that the config is already in sync and stop.

Derive the working set dynamically — do not hardcode paths:

```bash
chezmoi managed ~/.claude   # the set you are allowed to act on
```

Anything not in `chezmoi managed` is out of scope. You may *list* notable
untracked files for the user's awareness (e.g. a hand-written
`agents/foo.md`), but do not `chezmoi add` them unless the user explicitly
asks to start managing that file.

**JSON configs are noisy under raw `chezmoi diff`.** Claude Code rewrites
`settings.json` and reorders its keys, so `chezmoi diff` shows large
reorder/reformat hunks that are *not* real content changes. To see the true
semantic delta, compare the rendered source against the live file with sorted
keys:

```bash
diff <(chezmoi cat ~/.claude/settings.json | jq -S .) \
     <(jq -S . ~/.claude/settings.json)
```

`chezmoi cat` renders the source (templates included), and `jq -S` sorts keys,
so the only lines that survive are genuine additions/removals. Use this to drive
classification; treat the raw-diff reordering as DISCARD noise that `chezmoi
apply` will normalize after merge.

**Know whether the source is a template.** Resolve it once per path:

```bash
chezmoi source-path ~/.claude/settings.json   # → …/dot_claude/settings.json.tmpl
```

A `.tmpl` suffix means the source contains Go-template logic (e.g.
`settings.json.tmpl` guards its `env` block with
`{{- if hasKey . "bedrock_base_url" }}`). This changes how you ADOPT — see
step 5.

### 3. Examine each diff and classify

Read every hunk in `chezmoi diff ~/.claude` and sort each change into one of:

- **ADOPT** — a deliberate local edit that should live in the source.
- **DISCARD** — accidental or machine-specific drift that should *not* enter the
  source (e.g. a value you flipped while debugging, or a host-specific path).
- **PARTIAL / CONFLICT** — a single file mixes ADOPT and DISCARD hunks. This is
  the core case. Example: `settings.json` where you want to keep a new
  `effortLevel: "high"` but the same file also dropped an `env` block or a `tui`
  setting you did *not* mean to remove.
- **FORGET** — a managed file you intentionally deleted locally and want to stop
  tracking.

Lean on understanding, not rote rules: a change that makes the config better for
*every* machine is usually ADOPT; a change that only makes sense on this laptop,
or that looks like leftover experimentation, is usually DISCARD. When a hunk is
genuinely ambiguous, surface it rather than guessing.

### 4. Propose, then confirm once

Present a single classification table — path, the change, and proposed action
(ADOPT / DISCARD / PARTIAL / FORGET) with a one-line rationale each — and get
**one batched confirmation** before touching anything. Don't ask per-hunk; do
ask if something is ambiguous enough that guessing wrong would be costly.

### 5. Apply to the source only

After confirmation, act under `$SRC`:

- **ADOPT (non-template source)** → `chezmoi re-add <path>` (updates the source
  from the live target for already-managed files). `re-add` will not introduce
  new files, which keeps scope honest.
- **ADOPT (`.tmpl` source)** → **never `chezmoi re-add`.** `re-add` overwrites the
  source with the *rendered* output, destroying the `{{ }}` template logic (e.g.
  it would collapse `settings.json.tmpl`'s bedrock `{{- if … }}` branch into
  whatever this machine happened to render). Instead hand-edit the source
  `.tmpl` (e.g. `$SRC/dot_claude/settings.json.tmpl`) to add *only* the adopted
  change, leaving every `{{ }}` block untouched — exactly like the PARTIAL case
  below. The normalized `diff <(chezmoi cat …) <(jq -S …)` from step 2 tells you
  precisely which line(s) to add.
- **PARTIAL** → do *not* `re-add` the whole file. Open the source file
  (e.g. `$SRC/dot_claude/settings.json`) and hand-edit it so it contains the
  ADOPT hunks and *omits* the DISCARD hunks. This is the conflict resolution —
  the source ends up as the deliberate union you actually want.
- **FORGET** → `chezmoi forget --force <path>` (removes it from the source
  without deleting the live file).
- **DISCARD** → **report only.** List these as "drift left on the live machine".
  If the user wants them reverted, note that it requires `chezmoi apply <path>`
  (or a `git restore` in the source then apply) and per the repo's standing rule
  must wait until after the PR merges — it is out of scope for this skill.

### 6. Verify

- `git -C "$SRC" status` and `git -C "$SRC" diff` — confirm the source now
  reflects exactly the intended changes and nothing else (no noise files crept
  in; the expanded `.chezmoiignore` should prevent that).
- `chezmoi diff ~/.claude` again — the remaining diff should be only the DISCARD
  items you deliberately left, or the cosmetic key-reorder noise (which `chezmoi
  apply` normalizes after merge); the normalized `diff <(chezmoi cat …) <(jq -S …)`
  should now show no genuine content delta.
- If you hand-edited a `.tmpl`, run `make lint-tmpl` (or
  `scripts/check-json-tmpl.sh`) from `$SRC` to prove the template still renders
  to valid JSON on *both* branches (default and bedrock) — a stray comma is easy
  to introduce and `chezmoi diff` alone will not catch it.
- Run `make lint` (which now runs `lint-json` + `lint-tmpl`) from `$SRC` so the
  change passes the same checks CI will run.

### 7. Ship it (PR-driven)

Follow the repo workflow: work on a branch, commit with a Conventional Commits
message (scope `claude`), push. Ask before opening the PR. Never use
`--no-verify`. The new skill/source reaches the live `~/.claude/` only after the
PR is merged and `chezmoi apply` is run — which is the normal, reviewed path.

## Notes

- The reconcile is intentionally one-directional into the source. Pushing the
  source onto the live machine (`chezmoi apply`) is a separate, post-merge step
  and is never done here.
- If `chezmoi status` is empty, there is nothing to do — say so plainly instead
  of inventing work.
- Keep commits granular (per skill / per concern) so any single change is easy to
  revert later via the source's git history.
