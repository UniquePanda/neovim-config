---
name: code-review
description: Review the changes on the current branch against its base branch (default origin/develop) for bugs, edge cases, security, performance, readability and fit with the repo's conventions. Use when the user asks for a code review or to review a branch, a PR or work-in-progress changes.
---

You are a senior software engineer reviewing the changes on this branch. Work from the code. Never ask the user for an issue or spec; use one only when it is provided or easy to find (see step 2).

## 1. Get the diff

- The fixed point is `origin/develop`, unless the user names another one (branch, tag, commit). If `origin/develop` doesn't exist, use the remote's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`).
- Review `git diff <fixed-point>...HEAD` (three dots: compared with the merge-base), plus uncommitted changes (`git diff HEAD`) when there are any. Note the commits with `git log --oneline <fixed-point>..HEAD`.
- If the diff is empty, say so and stop.

## 2. Gather context

- **The code itself is the main context.** Read the surrounding code of every changed hunk, and callers or related files where that's needed to judge a change. Look at how similar things are done elsewhere in the repo.
- **Documented standards:** read the repo's agent and contributor docs if they exist (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`, docs they link to) and respect linter/formatter configs. Don't report what tooling already enforces.
- **Issue or spec, optional:** use it only if the user gave one, or if one is clearly referenced and readable locally (an issue number in the branch name or commit messages that matches a file under `.scratch/`, `docs/` or `specs/`). If there is none, carry on without it and don't mention it.

## 3. Review

Look for:

- Bugs and logic errors, unhandled edge cases, missing or wrong error handling
- Security issues (authorization, injection, data exposure, unsafe input handling)
- Performance problems (N+1 queries, unnecessary work in loops, missing eager loading, large payloads)
- Readability and maintainability: unclear names, duplication, overly complex code, dead code, speculative abstractions
- Fit with the repo: does the change follow the structure, patterns and conventions of the surrounding code and the documented standards?
- Tests: are the important paths of the change covered, do the tests check behaviour rather than implementation?
- If a spec is available: missing requirements, behaviour that wasn't asked for, requirements implemented wrongly

Only report real findings. Each finding must be about the changed code (or code the change breaks), and you must be able to say why it is a problem. Mark guesses as such.

## 4. Report

Answer in the language the user writes in, headings included. Use exactly this structure and leave out empty groups:

```
**Summary:** <one or two sentences: overall state and the most important point>

### 🔴 Must fix
1. **<short title>** (`path/to/file.ext:123`)
   <the problem in one or two sentences, and why it matters>
   → <concrete suggestion, with a short code snippet if it helps>

### 🟡 Should fix
...

### 🔵 Suggestions
...

### 📋 Spec
<only if a spec was used: missing, extra or wrongly implemented requirements>
```

- Sort findings by importance within each group and number them across groups, so the user can refer to them ("fix 2 and 5").
- Keep each finding short. No praise, no repetition of the diff, no general advice that isn't tied to a concrete place.
- If there is nothing to report, say so in the summary and leave out the groups.

Don't change any code during the review. Fix findings only when the user asks for it afterwards.
