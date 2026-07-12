# Task Proposal: PaddlePaddle__Paddle-76259

## 1. 来源信息

- Instance ID：`PaddlePaddle__Paddle-76259`
- PR 链接：https://github.com/PaddlePaddle/Paddle/pull/76259
- PR 标题：`[Bug fixes] Fix Windows UTF-8 path support for Paddle Inference model/json files`
- `base_commit`：`fcf3b100085b10efed4c1fb8880b1df1fd5241d6`
- merged 时间：`2025-11-06`
- 你的身份：原 PR 作者
- 后续联系人：`@Echo-Nie`

## 2. 问题一句话

在 Windows 上，Paddle Inference 通过 `paddle.inference.Config` 或底层 helper 检查模型文件/目录时，如果路径中包含中文等非 ASCII 字符，文件实际存在但可能被错误判断为无法打开。该 PR 修复了 Paddle Inference 在 Windows 上对 UTF-8 编码路径的文件存在性和目录判断支持。

## 3. 为什么适合作为 SWE-Paddle 样本

- **真实性**：该问题来自真实 Windows 用户场景。用户路径中包含 `模型` 等中文字符，Python 层 `os.path.exists(...)` 可以确认 `.pdmodel` / `.pdiparams` 文件存在，但 Paddle Inference 在创建 `paddle.inference.Config` 时仍可能报出无法打开文件。
- **代表性**：该任务代表 Paddle Inference 在 Windows 文件系统、UTF-8 路径、C++ helper、Python API 调用链路上的跨平台工程问题。它不是纯 API 参数校验，也不是格式化或重命名。
- **边界清楚**：目标行为是 Windows 上能正确识别 UTF-8 编码的中文文件路径和目录路径；非 Windows 平台路径逻辑不应被改变。
- **非平凡性**：虽然最终 patch 只改一个 C++ header，但 agent 需要理解 Windows narrow path 与 wide-char API/UTF-16 路径的差异，并通过 `_WIN32` 条件编译隔离平台逻辑。
- **可验证性**：可以在 Windows C++ 单测中创建包含中文字符的临时目录和文件，分别验证 `paddle::inference::IsDirectory` 与 `paddle::inference::IsFileExists`。在 base commit 上应用 test patch 应失败；应用 code patch 后应通过。
- **任务粒度合适**：核心改动集中在 `paddle/fluid/inference/api/helper.h` 的 `IsFileExists` 和 `IsDirectory`，没有混入多个独立目标。

## 4. 任务类型和标签

- 任务类型：`bug_fix`
- 执行后端：`cpu`
- 设备范围：`cpu_only`
- 模块标签：`[inference, windows, utf8_path, file_system, cpp_helper, cross_platform]`

## 5. 验证思路

- 目标测试文件 / 命令：
  - `test/cpp/inference/api/utf8_path_test.cc`
  - `test/cpp/inference/api/CMakeLists.txt`
  - 最小命令：`bash tests/test.sh`
- 修复前预期：
  - 在 Windows 上，`base_commit + tests/test.patch` 后，测试会创建包含中文字符的临时目录，例如 `paddle_inference_模型路径测试`，并在其中创建 `inference.pdmodel` 文件。
  - 测试将 Windows UTF-16 路径转换为 UTF-8 `std::string`，再调用 `paddle::inference::IsDirectory` 和 `paddle::inference::IsFileExists`。
  - base 版本中，Windows 下仍使用 narrow path 的 `std::ifstream` / `stat` 路径检查，中文路径场景应失败。
- 修复后预期：
  - 应用 `solution/code.patch` 后，Windows 分支通过 UTF-8 到 UTF-16 的转换，并使用 wide path 文件/目录检查逻辑。
  - 同一个中文路径测试应通过。
  - 非 Windows 平台保持原有路径检查逻辑不变。
- P2P 候选：
  - Paddle Inference API 相关 C++ 单测
  - `test/cpp/inference/api` 下已有 helper/config/model loading 相关测试
  - 非 Windows 平台原有 `IsFileExists` / `IsDirectory` 行为不应被破坏

## 6. 环境与资源

- 是否能提供 Docker：无
- Dockerfile 或镜像地址：暂无
- Paddle 来源：source build
- 如果使用 wheel，请填写 wheel URL、Python 版本和平台标签：不适用；该任务涉及 C++ helper 修改和 C++ 单测，需要 source build。
- OS / Python / CUDA / cuDNN / 其他关键依赖：
  - OS：Windows
  - Python：以 Paddle Windows source build 环境为准
  - CUDA / cuDNN：不需要
  - 关键依赖：CMake、MSVC、gtest、Paddle Inference C++ build/test 依赖
- 硬件：CPU
- patch 类型：含 C++，不含 CUDA，不含 kernel，不含 infermeta 编译
- 最小测试命令：`bash tests/test.sh`
- 是否有 oracle 日志：无；后续由 GitHub Actions Windows runner 或 SWE-Paddle verifier 运行 Run/Test/Fix 产生

## 7. 风险自查

- 泄露风险：正式 `instruction.md` 应描述 Windows UTF-8 路径下 Paddle Inference 文件/目录识别失败的行为，不应直接提示具体实现方式，例如 `std::wstring_convert`、`GetFileAttributesW` 或 wide path stream。
- 环境风险：这是 Windows-specific bug。Linux/AutoDL 不能有效暴露原始问题；该样本必须使用 Windows CPU verifier。
- flaky 风险：测试只依赖本地临时目录和本地文件系统，不涉及网络、随机数、多卡或外部数据；flaky 风险较低。
- 拆分风险：PR 只修改一个 helper 文件，核心目标是统一修复 Windows UTF-8 文件与目录路径检查，不需要拆成多个样本。
- 其他不确定点：需要确认 Windows verifier 支持创建包含中文字符的临时目录，并确保测试源文件以 UTF-8 编码保存。
