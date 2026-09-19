# my-dotfiles

这套配置使用 GNU Stow 管理，目标目录为 `$HOME`。仓库中的一级目录各自是一个 Stow package。

## 当前机器

- Ubuntu 22.04 VMware 虚拟机；
- Conda 位于 `~/anaconda3`；
- YSYX 工作区位于 `~/1-ysyx`；
- AMD/Xilinx 2023.2 位于 `~/tools/Xilinx`；
- RISC-V 工具链位于 `/opt/riscv`；
- Codex 通过 npm 安装到 `~/.npm-global`；
- Claude Code 使用原生安装器，当前命令位于 `~/.local/bin/claude`。

`.bashrc` 对可选工具都先检查路径或命令是否存在，避免迁移到另一台机器后登录 shell 报错。`ysyx_env` 只在需要时启用 YSYX 自带的 OSS CAD Suite，平时继续使用系统 Verilator。

## 部署

首次部署前，先确认目标位置没有需要保留的普通文件。然后在仓库目录执行：

```bash
cd ~/.dotfiles
stow -t "$HOME" bash profile npm conda git nvim tmux vim vscode
```

预览而不修改：

```bash
stow -n -v -t "$HOME" bash profile npm conda git nvim tmux vim vscode
```

取消某个 package 的链接：

```bash
stow -D -t "$HOME" bash
```

修改配置时直接编辑 `$HOME` 下的符号链接目标即可，改动会进入本仓库。机器凭据、API key、SSH 私钥和应用会话不应提交到这里。
