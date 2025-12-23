# cc-manager 使用指南

## 快速开始

### 一次性设置（必须）

为了让 `cc-manager switch` 命令能够正确设置环境变量，你需要启用 Shell 集成：

**添加到 `~/.bashrc` 或 `~/.zshrc`：**

```bash
# cc-manager shell integration
if [[ -f "/usr/local/lib/cc-manager/shell-integration.sh" ]]; then
    source "/usr/local/lib/cc-manager/shell-integration.sh"
elif [[ -f "$HOME/.local/lib/cc-manager/shell-integration.sh" ]]; then
    source "$HOME/.local/lib/cc-manager/shell-integration.sh"
fi
```

**重新加载 shell：**

```bash
source ~/.bashrc  # 或 ~/.zshrc
```

就这么简单！设置完成后，所有 `cc-manager` 命令都能正常工作。

## 基本用法

启用 Shell 集成后，你可以像平常一样使用 `cc-manager`：

### 列出提供商

```bash
cc-manager list
```

### 切换提供商

```bash
cc-manager switch deepseek
# 或简写
cc-manager sw deepseek
```

环境变量会自动在你当前的 shell 中设置！

### 查看状态

```bash
cc-manager status
# 或简写
cc-manager st
```

### 返回上一个提供商

```bash
cc-manager back
# 或简写
cc-manager b
```

### 测试连接

```bash
cc-manager test
```

### 其他命令

```bash
cc-manager add <name>      # 添加新提供商
cc-manager config edit     # 编辑配置
cc-manager history         # 查看历史
cc-manager help            # 显示帮助
```

## 工作原理

### 启用 Shell 集成后

当你执行 `cc-manager switch deepseek` 时：

1. **Shell 函数拦截** - `cc-manager` 是一个 shell 函数（不是直接的命令）
2. **识别命令类型** - 函数识别出这是 `switch` 命令
3. **调用实际程序** - 调用 `cc-manager-bin` 并获取导出命令
4. **注入环境变量** - 在当前 shell 中执行 `eval` 设置环境变量
5. **显示结果** - 显示切换成功的消息

结果：环境变量在**你的当前 shell** 中设置，而不是在子进程中！

### 未启用 Shell 集成

如果你没有 source shell-integration.sh，`cc-manager` 会检测到并显示帮助信息：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  IMPORTANT: Shell Integration Required
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For 'switch' and 'back' commands to work properly...
```

然后它会继续执行命令，但环境变量不会持久化。

## 验证设置

检查 Shell 集成是否正确启用：

```bash
# 1. 检查 cc-manager 是否是函数
type cc-manager
# 应该输出: cc-manager is a function

# 2. 切换提供商
cc-manager switch deepseek

# 3. 验证环境变量
echo $ANTHROPIC_BASE_URL
# 应该输出: https://api.deepseek.com/anthropic

# 4. 确认状态一致
cc-manager status
# BASE_URL 应该匹配上面的 echo
```

如果所有步骤都正确，说明设置成功！

## 常见问题

### Q: 为什么需要 Shell 集成？

**A:** 因为 Unix/Linux 的进程模型限制，子进程无法修改父进程的环境变量。Shell 集成通过使用 shell 函数来绕过这个限制。

### Q: 不启用 Shell 集成会怎样？

**A:** `cc-manager` 仍然可以运行，但环境变量不会持久化到你的 shell。这意味着切换提供商后，环境变量实际上没有改变。

### Q: Shell 集成会影响性能吗？

**A:** 几乎不会。函数调用非常快，只有在执行 `switch` 或 `back` 命令时才会做额外处理。

### Q: 我可以在脚本中使用吗？

**A:** 可以！在脚本中 source shell integration 文件：

```bash
#!/bin/bash
source /usr/local/lib/cc-manager/shell-integration.sh
cc-manager switch deepseek
echo "Using: $ANTHROPIC_BASE_URL"
```

### Q: 多个终端窗口怎么办？

**A:** 每个终端有独立的环境。你需要在每个终端中分别切换提供商。

### Q: 我忘记了 source shell-integration 会怎样？

**A:** `cc-manager` 会检测到并显示帮助信息，提醒你如何启用。命令仍会执行，但环境变量不会持久化。

## 便捷别名

Shell 集成还提供了一些便捷别名：

```bash
ccm           # 等同于 cc-manager
ccm-sw        # 等同于 cc-manager switch
ccm-st        # 等同于 cc-manager status
ccm-ls        # 等同于 cc-manager list
ccm-t         # 等同于 cc-manager test
ccm-b         # 等同于 cc-manager back

ccs deepseek  # 切换并显示状态
```

## 完整示例

```bash
# 一次性设置（添加到 ~/.bashrc）
echo 'source /usr/local/lib/cc-manager/shell-integration.sh' >> ~/.bashrc
source ~/.bashrc

# 日常使用
cc-manager list                    # 查看所有提供商
cc-manager switch deepseek         # 切换到 DeepSeek
echo $ANTHROPIC_BASE_URL           # 验证环境变量
cc-manager status                  # 查看当前状态
cc-manager test                    # 测试连接

# 切换到另一个提供商
cc-manager switch glm              # 切换到 GLM
cc-manager status                  # 确认切换成功

# 返回上一个
cc-manager back                    # 返回 DeepSeek

# 使用别名（更快）
ccm ls                             # 列出提供商
ccm sw deepseek                    # 切换
ccs glm                            # 切换并显示状态
```

## 技术细节

如果你对实现细节感兴趣：

### 架构

```
cc-manager (shell function)
    ↓
    ├─ switch/back → cc-manager-bin + eval
    └─ other commands → cc-manager-bin (passthrough)
```

### 文件

- `bin/cc-manager` - 包装脚本（检测是否需要提示用户）
- `bin/cc-manager-bin` - 实际的可执行程序
- `scripts/shell-integration.sh` - Shell 函数定义
- `lib/*.sh` - 核心库文件

### 环境变量导出

当执行 `CC_EXPORT_MODE=1 cc-manager-bin switch <provider>` 时，程序会输出：

```bash
# cc-manager export commands
unset ANTHROPIC_API_KEY
unset ANTHROPIC_AUTH_TOKEN
...
export ANTHROPIC_BASE_URL="https://api.example.com"
export ANTHROPIC_AUTH_TOKEN="sk-xxx"
```

Shell 函数捕获这些命令并使用 `eval` 在当前 shell 中执行。

## 总结

**关键点：**
1. ✅ 一次性设置：source shell-integration.sh
2. ✅ 然后正常使用 `cc-manager` 命令
3. ✅ 环境变量自动持久化
4. ✅ 所有命令都使用统一的 `cc-manager` 接口

**无需记忆新命令！一切都是 `cc-manager <command>`！**

---

需要帮助？运行 `cc-manager help` 或查看 [README.md](README.md)
