# Release Notes v1.0.2

## 统一命令接口

基于用户反馈，v1.0.2 简化了命令接口，**无需学习新命令**！

### 问题回顾

在 v1.0.1 中，我们引入了新的命令（`cc-switch`）来解决环境变量持久化问题，但这要求用户：
- 记住两套命令
- 切换时用 `cc-switch`
- 其他操作用 `cc-manager`

**这不够简洁！**

### 新的解决方案

v1.0.2 重新设计了架构，现在：
- ✅ **统一使用 `cc-manager` 命令**
- ✅ 无需记忆新命令
- ✅ 环境变量自动持久化
- ✅ 一次设置，永久生效

### 使用方式

**一次性设置（在 ~/.bashrc 或 ~/.zshrc 中添加）：**

```bash
# cc-manager shell integration
source /usr/local/lib/cc-manager/shell-integration.sh
```

**然后正常使用：**

```bash
cc-manager switch deepseek  # ✅ 就这么简单！
cc-manager status           # ✅ 查看状态
cc-manager back             # ✅ 返回上一个
```

环境变量自动在当前 shell 中设置！

## 技术变更

### 架构重构

1. **双二进制架构**
   - `cc-manager` - 包装脚本（提供友好提示）
   - `cc-manager-bin` - 实际的可执行程序

2. **智能 Shell 函数**
   - `cc-manager` 作为 shell 函数
   - 自动识别命令类型
   - 对 `switch`/`back` 注入环境变量
   - 其他命令直接透传

3. **用户友好**
   - 未启用集成时显示帮助
   - 清晰的设置说明
   - 命令仍然执行（虽然变量不持久）

### 文件变更

**新增：**
- `bin/cc-manager` - 包装脚本
- `USAGE_GUIDE.md` - 详细使用指南

**重命名：**
- `bin/cc-manager` → `bin/cc-manager-bin`

**更新：**
- `scripts/shell-integration.sh` - 重写为智能函数
- `install.sh` - 安装两个二进制文件
- `uninstall.sh` - 卸载两个二进制文件
- `Makefile` - 更新验证和测试
- `lib/core.sh` - 版本更新为 1.0.2

**移除：**
- 不再需要单独的 `cc-switch` 命令
- 简化了文档

## 迁移指南

### 从 v1.0.1 升级

如果你使用了 v1.0.1 的 `cc-switch`：

```bash
# 旧方式 (v1.0.1)
cc-switch deepseek     ❌ 不再需要
cc-back               ❌ 不再需要

# 新方式 (v1.0.2)
cc-manager switch deepseek  ✅ 统一命令
cc-manager back             ✅ 统一命令
```

### 升级步骤

1. **更新代码**
   ```bash
   cd cc-manager
   git pull  # 或重新下载
   ```

2. **重新安装**
   ```bash
   make dev-install  # 或 make install
   ```

3. **Shell 集成保持不变**
   ```bash
   # 你的 ~/.bashrc 或 ~/.zshrc 中应该有：
   source /usr/local/lib/cc-manager/shell-integration.sh
   # 保持这行不变即可！
   ```

4. **重新加载 shell**
   ```bash
   source ~/.bashrc  # 或 ~/.zshrc
   ```

5. **验证**
   ```bash
   type cc-manager
   # 应该输出: cc-manager is a function
   ```

6. **使用新命令**
   ```bash
   cc-manager switch deepseek
   echo $ANTHROPIC_BASE_URL  # 应该显示正确的 URL
   ```

## 命令对照表

| 用途 | v1.0.1 | v1.0.2 (新) |
|------|--------|------------|
| 切换提供商 | `cc-switch deepseek` | `cc-manager switch deepseek` ✅ |
| 快速切换+状态 | `ccs deepseek` | `ccs deepseek` ✅ |
| 返回上一个 | `cc-back` | `cc-manager back` ✅ |
| 列出提供商 | `cc-manager list` | `cc-manager list` ✅ |
| 查看状态 | `cc-manager status` | `cc-manager status` ✅ |

**结论：现在一切都是 `cc-manager`！**

## 示例对比

### Before (v1.0.1)

```bash
# 需要记住两套命令
cc-switch deepseek      # 切换用这个
cc-manager list         # 列表用这个
cc-manager status       # 状态用这个
cc-back                 # 返回用这个

# 容易搞混！
```

### After (v1.0.2)

```bash
# 统一命令接口
cc-manager switch deepseek  # ✅ 清晰一致
cc-manager list             # ✅ 清晰一致
cc-manager status           # ✅ 清晰一致
cc-manager back             # ✅ 清晰一致

# 简单明了！
```

## 验证修复

测试你的问题是否已解决：

```bash
# 在你的服务器上
jone@kvm-aigc:~$ cc-manager switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic
  MODEL: deepseek-chat

jone@kvm-aigc:~$ echo $ANTHROPIC_BASE_URL
https://api.deepseek.com/anthropic  # ✅ 正确！

jone@kvm-aigc:~$ cc-manager status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Claude Code Configuration Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Provider:    deepseek

Environment Variables:
  BASE_URL:   https://api.deepseek.com/anthropic  # ✅ 匹配！
  AUTH_TOKEN: ***b9d9fd
  MODEL:      deepseek-chat
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

完美！✅

## Breaking Changes

**无破坏性变更！**

- 如果你用的是 `cc-manager` 命令 → 无需改变
- 如果你用的是 `cc-switch` → 改为 `cc-manager switch`（更清晰）

Shell 集成配置保持不变。

## 文档

**新增：**
- `USAGE_GUIDE.md` - 完整使用指南（中文）

**更新：**
- `README.md` - 更新使用说明
- `CHANGELOG.md` - 添加 v1.0.2 记录

**废弃：**
- `QUICK_FIX.md` - 已过时
- `IMPORTANT_USAGE.md` - 用 USAGE_GUIDE.md 替代

## 已知问题

无

## 下一步计划

- Homebrew formula
- Fish shell 支持
- 配置向导
- 更多测试

## 致谢

感谢用户反馈，帮助我们改进命令接口！

---

**版本**: 1.0.2
**发布日期**: 2025-12-23
**上一版本**: 1.0.1

**核心理念**: Keep It Simple! 统一使用 `cc-manager`，一个命令走天下！
