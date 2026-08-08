# PaddlePaddle__Paddle-77216

This directory converts Paddle PR #77216 into a SWE-Paddle community task candidate.

## Source

| Field | Value |
| --- | --- |
| Repo | `PaddlePaddle/Paddle` |
| PR | [77216](https://github.com/PaddlePaddle/Paddle/pull/77216) |
| PR title | `[CUDAExtension] Refactor the CUDA architecture flag retrieval function` |
| Base commit | `76b27614e66640189c3f5411f09b7bab3ca696f7` |
| Merged at | `2026-01-07T21:44:44+08:00` |
| Task type | `refactor` |
| Resource | CPU |

## Summary

Ensure the CUDAExtension dlink flag preparation path derives CUDA architecture flags consistently without requiring a real GPU or Paddle source build for verification.

## Why This Is A Good SWE-Paddle Candidate

- It represents execute-infrastructure refactoring rather than an API addition or model-level bug fix.
- The Base failure is directly observable in generated NVCC flags used by CUDAExtension.
- The verifier can execute the checkout's real Python control flow with deterministic CUDA device doubles on CPU.
- Existing explicit architecture flags are protected by a P2P regression test.

## Files

- `proposal.md`: candidate proposal for maintainer triage.
- `instruction.md`: self-contained problem statement for the coding agent.
- `solution/code.patch`: gold patch from the merged PR.
- `tests/test.patch`: test patch exposing the target behavior.
- `tests/test.sh`: minimal target test command.
- `environment/README.md`: environment notes for reproduction.
- `README.md`: task overview and verification entrypoint.

## Verification

```bash
bash tests/test.sh
```

Expected behavior: applying `tests/test.patch` to `base_commit` should fail on the CUDA architecture flag behavior; applying both `tests/test.patch` and the exact Gold `solution/code.patch` should pass the target tests.
