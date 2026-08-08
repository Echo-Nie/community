# 修复 CUDAExtension dlink 阶段缺少 CUDA arch 编译参数

## 详细描述

在使用 Paddle 的 CUDAExtension 构建自定义 CUDA 算子时，不同编译阶段都需要根据目标 GPU 架构生成对应的 NVCC 编译参数。

目前在 dlink 阶段，即使已经通过 `PADDLE_CUDA_ARCH_LIST` 指定了 CUDA 架构，或者希望根据当前可见 GPU 自动确定架构，生成的编译参数中仍可能缺少对应的 `-gencode` 配置。这会导致 dlink 阶段没有按照目标 GPU 架构进行编译，和其他 CUDA 编译阶段的行为不一致。

希望 CUDAExtension 在准备 CUDA 编译参数时能够统一处理 CUDA arch 配置：显式指定架构时生成对应的 `-gencode` 参数；未指定时能够根据可见设备确定需要的架构；如果用户已经在编译参数中提供了 arch 配置，则不应重复添加。

## 验收说明

- 设置 `PADDLE_CUDA_ARCH_LIST` 后，CUDAExtension 准备的 CUDA 编译参数应包含对应的 `-gencode` 配置。
- 未显式设置 CUDA arch 时，应能够根据可见 GPU 的 capability 生成需要的架构参数，并为最高架构保留 PTX 兼容配置。
- 用户已经显式提供 arch 编译参数时，应保持原有参数且不能重复添加 CUDA arch 配置。

## 技术要求

- 熟悉 Paddle CUDAExtension 和自定义算子构建流程
- 熟悉 CUDA / NVCC 的 GPU architecture 编译参数
- 熟悉 Python 环境变量配置与回归测试

## 参考资料

- https://github.com/PaddlePaddle/Paddle/pull/77216

## Acceptance Criteria

- The behavior described above should be fixed.
- Existing valid behavior should remain unchanged.
- Do not satisfy the task by deleting tests, weakening assertions, or bypassing validation broadly.
