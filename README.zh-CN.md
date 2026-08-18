# cc-manager

> **Claude Code 供应商管理器** - 轻松管理与切换 Claude Code API 供应商

[English](README.md) | 中文文档

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

## 概述

`cc-manager` 是一个轻量级命令行工具，用于管理多个 Claude Code API 供应商。
一条命令切换供应商、管理配置、追踪切换历史。

## 特性

- ✨ **一键切换** - 单条命令在不同供应商之间切换
- 🔧 **任意环境变量** - 每个供应商可声明 `env` 块（模型映射、编译参数等），切换时自动设置、切走时自动清理
- 🔐 **安全配置** - 配置文件权限 600，密钥交互输入时不回显
- 📊 **状态监控** - 一目了然查看当前供应商与配置
- 📝 **历史管理** - 记录切换历史，快速回退
- 🎯 **交互菜单** - 友好的供应商选择菜单
- 🔍 **连接测试** - 使用前测试供应商连通性
- 🚀 **Shell 集成** - 别名与补全，加速日常操作
- 📦 **极少依赖** - 纯 Bash 4+ 实现，无其他依赖

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/keepwonder/cc-manager.git
cd cc-manager

# 安装到 ~/.local（无需 sudo）
make dev-install

# 或系统级安装（需要 sudo，默认 /usr/local）
make install
```

> **macOS 用户注意**：系统自带 bash 为 3.2，本工具需要 bash 4+。
> 请先执行 `brew install bash` 并重启终端，否则安装脚本会明确报错。

### 启用 Shell 集成（推荐）

`switch` / `back` 需要把环境变量注入当前 shell，请将下面一行加入 `~/.bashrc` 或 `~/.zshrc`：

```bash
source /usr/local/lib/cc-manager/shell-integration.sh   # 系统级安装
# 或
source ~/.local/lib/cc-manager/shell-integration.sh     # 用户级安装
```

### 基本用法

```bash
cc-manager list              # 列出所有供应商
cc-manager switch deepseek   # 切换到 deepseek
cc-manager status            # 查看当前状态
cc-manager test              # 测试连通性
cc-manager back              # 切回上一个供应商
```

## 命令一览

| 命令 | 别名 | 说明 |
|------|------|------|
| `cc-manager switch <provider>` | `sw` | 切换到指定供应商 |
| `cc-manager status` | `st` | 查看当前配置状态 |
| `cc-manager list` | `ls` | 列出所有可用供应商 |
| `cc-manager menu` | `m` | 交互式供应商选择菜单 |
| `cc-manager back` | `b` | 切回上一个供应商 |
| `cc-manager test` | `t` | 测试当前供应商连通性 |
| `cc-manager run <provider>` | `r` | 用指定供应商运行 Claude Code |
| `cc-manager add <name>` | `a` | 交互式添加供应商 |
| `cc-manager remove <name>` | `rm` | 删除供应商（自动备份配置） |
| `cc-manager edit [name]` | `e` | 编辑供应商或配置文件 |
| `cc-manager config [action]` | `cfg` | 管理配置（show/edit/reset/validate） |
| `cc-manager history [limit]` | | 查看切换历史 |
| `cc-manager clear-history` | `ch` | 清空切换历史 |
| `cc-manager export [file]` | | 导出配置 |
| `cc-manager import <file>` | | 导入配置 |
| `cc-manager version` | `v` | 查看版本 |
| `cc-manager help` | `h` | 查看帮助 |

### Shell 别名（启用集成后）

```bash
ccm              # cc-manager 简写
ccm-sw deepseek  # 切换供应商
ccm-st           # 查看状态
ccm-ls           # 列出供应商
ccm-t            # 测试连通性
ccm-b            # 回退

ccs deepseek     # 切换并显示状态
ccmenu           # 交互菜单
```

## 配置

配置文件位于 `~/.config/cc-manager/config.yaml`：

```yaml
version: "1.0"
default_provider: "aicodemirror"

providers:
  aicodemirror:
    base_url: "https://api.aicodemirror.com/api/claudecode"
    auth_type: "api_key"
    api_key: "your-api-key-here"
    enabled: true

  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    auth_type: "auth_token"
    auth_token: "your-auth-token-here"
    model: "deepseek-chat"
    small_fast_model: "deepseek-chat"
    enabled: true

  glm:
    base_url: "https://open.bigmodel.cn/api/anthropic"
    auth_type: "auth_token"
    auth_token: "your-auth-token-here"
    model: "GLM-4.7"
    enabled: true
    env:
      ANTHROPIC_DEFAULT_OPUS_MODEL: "GLM-4.7"
      ANTHROPIC_DEFAULT_SONNET_MODEL: "GLM-4.6"
      ANTHROPIC_DEFAULT_HAIKU_MODEL: "GLM-4.5-air"
      CLAUDE_CODE_AUTO_COMPACT_WINDOW: "1000000"
```

### 供应商字段

| 字段 | 必填 | 说明 |
|------|------|------|
| `base_url` | ✅ | API 端点 URL |
| `auth_type` | ✅ | `api_key` 或 `auth_token` |
| `api_key` / `auth_token` | ✅ | 凭证（按 auth_type 二选一） |
| `model` | | 模型名 |
| `small_fast_model` | | 轻量快速模型名 |
| `enabled` | | 是否启用（默认 `true`） |
| `env` | | 任意环境变量块 |

### `env` 块（v1.1.0 新增）

`env` 下可声明任意 `KEY: "value"` 环境变量（KEY 须为合法环境变量名），切换到该供应商时自动设置。适合：

- 模型映射：`ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_HAIKU_MODEL`
- 供应商特有开关：如 `CLAUDE_CODE_AUTO_COMPACT_WINDOW`、`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`

切换时会先 unset **所有**供应商 `env` 块声明过的变量并集，再设置目标供应商的值，
因此变量绝不会跨供应商残留。固定字段（`base_url` 等 5 项）与 `env` 块可自由组合，
旧配置无需任何改动。

### 环境变量

| 变量 | 说明 |
|------|------|
| `CC_MANAGER_HOME` | 覆盖安装目录 |
| `CC_CONFIG_DIR` | 覆盖配置目录（默认 `~/.config/cc-manager`） |
| `EDITOR` | 配置编辑器 |
| `CC_DEBUG` | 设为 `1` 开启调试输出 |

## 开发

### 项目结构

```
cc-manager/
├── bin/
│   ├── cc-manager          # 包装脚本（前端）
│   └── cc-manager-bin      # 核心程序
├── lib/
│   ├── core.sh             # 命令分发与版本
│   ├── config.sh           # 配置解析与校验
│   ├── providers.sh        # 供应商管理与切换
│   ├── history.sh          # 历史管理
│   └── utils.sh            # 工具函数
├── config/
│   └── config.example.yaml # 配置示例
├── scripts/
│   └── shell-integration.sh # Shell 集成
├── docs/                   # 文档
├── tests/                  # 测试
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
└── Makefile                # 构建自动化
```

### 运行测试

```bash
make test           # 测试套件
make check-syntax   # 语法检查
make validate       # 综合校验
```

## 故障排除

### 提示需要 bash 4+

macOS 自带 bash 3.2，不支持本工具使用的关联数组：

```bash
brew install bash   # 然后重启终端
```

### 找不到命令

```bash
# 检查安装位置
ls -la /usr/local/bin/cc-manager     # 系统级
ls -la ~/.local/bin/cc-manager       # 用户级

# 用户级安装需要 PATH 包含 ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

### switch 后环境变量未生效

`switch` / `back` 依赖 Shell 集成（见"启用 Shell 集成"一节）。
未 source 集成脚本时，工具会提示并继续执行，但变量只在子进程内生效。

### 配置问题

```bash
cc-manager config validate   # 校验配置
cc-manager config reset      # 重置为默认（自动备份）
cc-manager config show       # 查看配置文件位置
```

## 卸载

```bash
make uninstall      # 系统级
make dev-uninstall  # 用户级
# 或
bash uninstall.sh
```

## 路线图

- [ ] Homebrew formula
- [ ] Fish shell 支持
- [ ] 供应商健康监控
- [ ] 使用统计
- [ ] 配置加密
- [ ] 配置云同步

## 许可

MIT License，详见 [LICENSE](LICENSE)。

## 相关链接

- [英文文档](README.md)
- [Issue 反馈](https://github.com/keepwonder/cc-manager/issues)
- [Discussions](https://github.com/keepwonder/cc-manager/discussions)
