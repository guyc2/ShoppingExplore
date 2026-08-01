---
name: review-pr
description: Review pull requests for security issues, migration risk, and missing tests. Use when reviewing a PR, a git diff, or a release-critical change.
---
# Review PR
1. Collect the diff and changed files.
2. Flag correctness, security, and test-coverage issues, grouped by severity.
3. **Verify Logging**: Explicitly check that `AppLogger` (`d`, `i`, `w`, `e`) is properly used across repositories, data sources, and view models/controllers to trace operations and failures. Flag any missing telemetry.
4. **Verify Error Handling**: Ensure no swallowed exceptions or empty `catch` blocks exist. Verify that domain operations return typed `Result<T>` and errors map cleanly to explicit `Failure` hierarchy types.
5. Cite file:line for every finding.
6. Suggest the smallest safe fix first.
