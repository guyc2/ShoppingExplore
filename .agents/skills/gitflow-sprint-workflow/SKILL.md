---
name: gitflow-sprint-workflow
description: Mandatory GitFlow branching, sprint execution, code review, testing, and merging workflow for ShoppingExplore. Use whenever developing features, creating branches, executing sprints, or merging pull requests.
---

# GitFlow Branching & Sprint Execution Workflow

This skill defines the mandatory GitFlow branching rules, multi-agent peer review audits, testing requirements, and sprint execution gates for **ShoppingExplore**.

## 1. Branching & GitFlow Hierarchy

- **`main` Branch**: Production-grade code.
  - **RULE**: NEVER develop, commit, or merge directly to `main`.
  - **RULE**: Merging `develop` into `main` is strictly reserved for the user or explicit user instruction.
- **`develop` Branch**: Main integration branch for all ongoing development.
  - Initialized from `main`.
  - Receives merges from completed sprint feature branches after tests and code review pass.
- **Feature/Sprint Branches**:
  - Dedicated branches for each feature or sprint (e.g., `feature/<name>` or `feature/<name>-sprint-<number>`).
  - Created from `develop` (or `main` at project initialization).

## 2. Multi-Agent Sprint Execution Protocol

For every feature sprint, execute the following strict sequence:

```mermaid
sequenceDiagram
    autonumber
    User->>Agent: Approve feature plan & sprint breakdown
    Agent->>Agent: Create & checkout feature branch (e.g. feature/shopping-list-sprint-2)
    Agent->>Agent: Implement Sprint deliverables (code + docs)
    Agent->>TestSubagent: Delegate test suite creation & execution
    TestSubagent-->>Agent: Pass all unit & integration tests
    Agent->>ReviewSubagent: Delegate PR / code review audit (review-pr skill)
    ReviewSubagent-->>Agent: Pass review (verifying AppLogger & error handling)
    Agent->>Agent: Merge feature branch into develop branch
    Agent->>User: STOP at Execution Gate — Present summary & await permission for next Sprint
```

### Mandatory Subagent Rules
1. **Testing Subagent**: Dedicated agent writes and runs unit/integration tests to guarantee unbiased test coverage.
2. **Reviewer Subagent (`review-pr` skill)**: Independent review audit must explicitly verify:
   - Clean Architecture compliance (no UI imports in domain layer).
   - Telemetry: Proper use of `AppLogger` (`d`, `i`, `w`, `e`) across repositories, data sources, and controllers.
   - Error Handling: Typed `Result<T>` and `Failure` hierarchy without swallowed exceptions.

## 3. Sprint Execution Gate (Strict Pause)

- **RULE**: Under no circumstances may an agent automatically proceed from Sprint $N$ to Sprint $N+1$.
- Upon completing Sprint $N$ (implementation + tests + review audit + merge to `develop`), the agent MUST **STOP** and wait for explicit user approval to resume to Sprint $N+1$.

## 4. Documentation Synchronization

- Any code, module, file, or architecture modification must be synchronously updated in `/docs/` using Obsidian-style markdown (YAML frontmatter, wikilinks, callouts, and Mermaid diagrams).
