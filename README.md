# GSD Workflow Commands

> Structured 5-stage development lifecycle for Cursor AI.
> Repo: [ben-smith-atg/cursor-gsd](https://github.com/ben-smith-atg/cursor-gsd)

## Install / Update

Requires the [gh CLI](https://cli.github.com) authenticated with access to `ben-smith-atg/cursor-gsd`.
Installs all GSD commands to `~/.cursor/commands/gsd/`. Re-running updates files in place.

**macOS / Linux:**

```bash
gh api repos/ben-smith-atg/cursor-gsd/contents/install.sh --jq '.content' \
  | base64 -d | bash
```

**Windows (PowerShell):**

```powershell
gh api repos/ben-smith-atg/cursor-gsd/contents/install.ps1 --jq '.content' `
  | % { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) } `
  | iex
```

> If the repo is made public in future, the macOS/Linux install simplifies to:
> `curl -fsSL https://raw.githubusercontent.com/ben-smith-atg/cursor-gsd/main/install.sh | bash`

---

# Cursor Commands Quick Reference

All commands can be accessed with **2 letters** for fast autocomplete.

## Command Directory

### Quality Commands (`q*`)

| Type | Name               | Purpose                 | Scope                   |
| ---- | ------------------ | ----------------------- | ----------------------- |
| `qc` | qc-commit-check.md | Pre-commit quality gate | Modified + staged files |
| `qb` | qb-branch-check.md | Pre-PR quality gate     | Branch vs origin/main   |
| `qa` | qa-full-check.md   | Full project audit      | All project files       |
| `qe` | qe-test-expand.md  | Expand test coverage    | Changed files           |

**Quality workflow**: All `q*` commands run Codacy → Lint → Tests iteratively (up to 5 iterations each).

### Git Commands (`g*`)

| Type | Name                 | Purpose                 |
| ---- | -------------------- | ----------------------- |
| `gc` | gc-commit-message.md | Generate commit message |
| `gm` | gm-merge-resolve.md  | Resolve merge conflicts |
| `gr` | gr-code-review.md    | Human-style code review |

### Research Commands (`r*`)

| Type | Name                | Purpose                |
| ---- | ------------------- | ---------------------- |
| `ra` | ra-api-check.md     | Backend API analysis   |
| `rd` | rd-deep-research.md | Deep research protocol |

### Ticket Commands (`t*`)

| Type | Name              | Purpose              |
| ---- | ----------------- | -------------------- |
| `tp` | tp-ticket-plan.md | JIRA ticket planning |

### GSD Workflow (`*-gsd`)

**Get Shit Done**: Structured 5-stage development lifecycle with persistent context

| Stage | Command        | Purpose                                | File                |
| ----- | -------------- | -------------------------------------- | ------------------- |
| 0     | `/setup-gsd`   | One-time project config setup          | setup-gsd.md        |
| 1     | `/spec-gsd`    | Research & requirements gathering      | spec-gsd.md         |
| 2     | `/plan-gsd`    | Architecture & implementation planning | plan-gsd.md         |
| 3     | `/build-gsd`   | Code execution (no tests)              | build-gsd.md        |
| 4     | `/verify-gsd`  | Tests + lint + Codacy + commit         | verify-gsd.md       |
| 5     | `/retro-gsd`   | Process improvement & learning         | retro-gsd.md        |

**Key Features**:
- **Project Config**: One-time `/setup-gsd` creates `.cursor/rules/gsd-project.mdc` — pkg manager, commands, base branch, API contract paths
- **Context Persistence**: All work saved to `.cursor/plans/[TICKET-ID].md`
- **Jira Integration**: Detects any project prefix (WBPR-, SP2-, HUI-, etc.), fetches tickets and attachments
- **Clean BUILD/VERIFY Split**: BUILD = production-quality code, no tests. VERIFY = writes tests + runs global suite + lint + Codacy + commit
- **PR Draft**: 3-tier template detection (repo template → gh history → generic fallback)
- **Self-Improving**: RETRO stage updates cursor rules based on learnings
- **Survives Context Resets**: Plan file preserves progress across sessions

## Typical Workflows

### Pre-Commit Workflow

```
1. Edit files
2. @qc (quality commit check)
3. @gc (generate commit message)
4. git commit
```

### Pre-PR Workflow

```
1. Feature work complete
2. @qb (quality branch check)
3. @gr (optional human review)
4. Create PR
```

### Merge Conflict Workflow

```
1. git merge main
2. Conflicts appear
3. @gm (intelligent merge resolution)
4. Review and commit
```

### Major Refactor Workflow

```
1. Complete refactor
2. @qa (full project quality audit)
3. Review comprehensive report
4. Address critical issues
5. @qb before PR
```

### JIRA Ticket Workflow (Original)

```
1. Receive ticket
2. @tp (analyze and plan)
3. Implement
4. @qe (expand test coverage)
5. @qc before commit
```

### GSD Workflow (New - Structured Lifecycle)

```
0. (First time in project) @setup-gsd → creates .cursor/rules/gsd-project.mdc
1. Receive ticket
2. @spec-gsd (research, fetch Jira, document in plan file)
3. @plan-gsd (create detailed implementation steps)
4. @build-gsd (write code — no tests, production quality)
5. [manual testing checkpoint]
6. @verify-gsd (write tests → global tests → global lint → Codacy → commit)
7. @pr-draft (creates draft PR, detects template automatically)
8. @retro-gsd (optional: learn and improve rules)
```

**When to use GSD vs. Original**:
- **GSD**: Complex features, multi-file changes, needs structure/tracking
- **Original** (`tp` + `q*`): Quick tasks, simple changes, ad-hoc fixes

## Command Categories

**Quality (`q`)**: Automated checks (Codacy, lint, tests)

- Focus: Tool-based quality gates
- Iterative: Yes (fixes issues automatically)
- Universal: Works with any Node.js project

**Git (`g`)**: Git workflow helpers

- Focus: Commit messages, merges, reviews
- Iterative: No (one-time analysis)
- Universal: Project agnostic

**Research (`r`)**: Deep analysis

- Focus: Investigation and planning
- Iterative: No (comprehensive output)
- Project: Varies by command

**Ticket (`t`)**: JIRA integration

- Focus: Ticket analysis and planning
- Iterative: No (planning phase)
- Universal: Works with any project

**GSD Workflow**: Structured development lifecycle

- Focus: Complete feature development with context persistence
- Iterative: Yes (multi-stage with quality gates)
- Context: Survives session resets via plan files
- Universal: Adapts to any project with package.json

## Project Compatibility

These commands work with any project that has:

- A `package.json` with `lint` and `test` scripts
- Standard JavaScript/TypeScript tooling

### Automatically Detected

Quality commands (`qc`, `qb`, `qa`) automatically detect:

- **Package manager**: pnpm, yarn, npm, or bun (via lockfiles)
- **Test framework**: Vitest, Jest, or generic (via devDependencies)
- **Available scripts**: lint, lint-fix, test, test:changed
- **Special requirements**: timezone settings, cross-env usage

### Optimized For

- ✅ wavebid-a2o-ui (Vitest + pnpm + UTC timezone)
- ✅ Any Next.js project
- ✅ Any React/TypeScript project
- ✅ Any Node.js project with standard scripts
- ✅ Turborepo monorepos

### Monorepo Support

Commands use **layered detection** for monorepos:

| Location                      | Detection           | Effect                      |
| ----------------------------- | ------------------- | --------------------------- |
| `monorepo/package-a/`         | Direct package.json | Checks that package only    |
| `monorepo/` (root with Turbo) | Turbo orchestration | Checks ALL Node.js packages |
| `monorepo/kotlin-backend/`    | No package.json     | Fails with clear message    |

**Turborepo Integration**:

- If monorepo root has `turbo.json` + scripts, commands work from root
- Running `@qb` from root checks ALL packages at once via turbo
- Great for ensuring entire monorepo is healthy before PR

**Example workflows for wavebid-a2o**:

```bash
# Option 1: Check just frontend
cd wavebid-a2o-ui && @qb

# Option 2: Check ALL Node.js packages from root
cd wavebid-a2o && @qb    # Runs turbo lint + test across all packages
```

## Quick Tips

- **Type 2 letters**: `@qc` autocompletes to qc-commit-check
- **Complementary commands**: `qb` + `gr` = full pre-PR validation
- **Sequential use**: `qc` → `gc` for perfect commits
- **Time estimates**:
  - `qc`: 1-5 minutes (few files)
  - `qb`: 5-15 minutes (branch changes)
  - `qa`: 30-60 minutes (full project)
  - `gc`, `gr`: 1-2 minutes (quick analysis)
  - `gm`: 5-20 minutes (depends on conflicts)
  - `tp`, `ra`, `rd`: Variable (research depth)

## Updates

**January 2025**: Original workflow commands implemented  
**January 2026**: GSD workflow added - structured 5-stage lifecycle with persistent context
