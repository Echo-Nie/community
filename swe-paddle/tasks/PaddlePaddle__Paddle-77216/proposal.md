# Task Proposal: PaddlePaddle__Paddle-77216

## 1. 来源信息

- Instance ID：`PaddlePaddle__Paddle-77216`
- PR 链接：https://github.com/PaddlePaddle/Paddle/pull/77216
- PR 标题：`[CUDAExtension] Refactor the CUDA architecture flag retrieval function`
- `base_commit`：`76b27614e66640189c3f5411f09b7bab3ca696f7`
- merged 时间：`2026-01-07T21:44:44+08:00`
- 你的身份：熟悉该模块的 contributor
- 后续联系人：TBD

## 2. 问题一句话

CUDAExtension 的 dlink 参数准备路径没有正确生成 CUDA architecture flags，导致该阶段不能与其他 CUDA 编译阶段一致地使用目标 GPU 架构配置。

## 3. 为什么适合作为 SWE-Paddle 样本

- **真实性**：来源于真实的 CUDAExtension Execute Infrastructure 改进，PR 描述明确指出 dlink 阶段缺少 CUDA arch 参数。
- **代表性**：覆盖自定义 CUDA 算子构建、NVCC 参数生成以及 CUDA architecture 配置，是框架执行基础设施中的典型维护工作。
- **边界清楚**：目标集中在 CUDA arch flags 的解析与编译参数准备，不涉及算子数值实现。
- **非平凡性**：修复不仅要让 dlink 路径获得 arch flags，还要保持显式 arch 参数不重复、环境变量解析以及自动设备探测等既有语义。
- **环境友好性**：测试通过 AST overlay 执行 checkout 中真实的参数准备逻辑，并用 controlled CUDA device doubles 模拟设备信息，无需 GPU、NVCC 或源码编译。

## 4. 任务类型和标签

- 任务类型：`refactor`
- 执行后端：`cpu`
- 设备范围：`cpu_only`
- 模块标签：`[CUDAExtension, cpp_extension, execute_infrastructure, refactor]`

## 5. 验证思路

- 目标测试命令：`bash tests/test.sh`
- 目标测试文件：`test/swe_paddle/test_pr77216_cuda_arch_flags.py`
- 修复前预期：显式 `PADDLE_CUDA_ARCH_LIST` 或自动设备探测都无法让 dlink 使用的 CUDA 参数准备路径生成对应 `-gencode` flags。
- 修复后预期：显式 arch 列表和自动设备探测都能生成稳定、正确的 architecture flags。
- P2P 候选：用户已经在 cflags 中显式提供 arch 参数时，该参数保持不变且不会重复生成。

## 6. 环境与资源

- 资源需求：CPU
- Paddle 来源：`PaddlePaddle/Paddle` source checkout at `base_commit`
- 是否能提供 Docker：暂无
- patch 类型：Python-only
- 环境建议：使用已安装 Paddle wheel 提供 pytest 运行环境；测试本身从 source checkout 提取目标函数并注入 controlled CUDA doubles，不要求真实 GPU 或 NVCC。
- 最小测试命令：`bash tests/test.sh`
- 是否有 oracle 日志：由 SWE-Paddle verifier 结果另行维护

## 7. 风险自查

- 泄露风险：instruction 只描述 dlink 阶段可观察到的 CUDA arch 参数缺失及兼容要求，不描述函数迁移位置、重复代码删除方式或 Gold patch 的具体实现。
- 环境风险：不调用真实 CUDA 编译、不要求 GPU，不依赖本机 CUDA toolkit。
- flaky 风险：GPU capability、device count 和编译状态由 deterministic doubles 提供，不依赖真实硬件或时序。
- 拆分风险：PR 的三个 production files 共同完成 helper 重构与调用路径统一，按同一 Gold patch 验证更符合原始改动边界。
