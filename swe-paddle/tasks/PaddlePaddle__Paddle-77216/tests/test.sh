#!/usr/bin/env bash

set -euo pipefail
python -m pytest test/swe_paddle/test_pr77216_cuda_arch_flags.py -q
