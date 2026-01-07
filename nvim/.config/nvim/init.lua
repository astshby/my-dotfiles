-- =======================================================
--  Neovim 通用配置 (Lua 版) - 适配 VSCode 与 纯终端
-- =======================================================

-- 1. 基础设置 (对应你原来的 set ignorecase 等)
vim.opt.ignorecase = true    -- 搜索忽略大小写
vim.opt.smartcase = true     -- 如果搜索包含大写，则不忽略
vim.opt.incsearch = true     -- 增量搜索 (输入时就高亮)
vim.opt.hidden = true        -- 允许隐藏未保存的 buffer

-- 2. 剪贴板设置 (对应 set clipboard)
-- 这一步非常重要，让 Vim 的复制(y) 和系统的 Ctrl+C 互通
vim.opt.clipboard = "unnamedplus"

-- 3. 缩进设置 (对应你原来的 tabstop=4 等)
-- 虽然 VSCode 有自己的缩进设置，但 Neovim 内部逻辑也需要同步，
-- 否则用 > 或 < 缩进时距离会不对。
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true     -- 将 Tab 转为空格
vim.opt.autoindent = true
vim.opt.smartindent = true

-- =======================================================
--  条件判断：VS Code 模式 vs 纯终端模式
-- =======================================================
if vim.g.vscode then
    -- [[ VS Code 特有设置 ]]
    -- 在 VS Code 里，我们要禁用高亮和行号，因为 VS Code 已经有了
    -- 如果 Neovim 也渲染，会重叠或者变卡
    
    -- 这里的按键映射是为了让你在 VS Code 里用 Vim 键位调用 GUI 功能
    -- 例如：按 <空格>rn 调用 VS Code 的重命名功能
    vim.g.mapleader = " "
    
    -- 映射：空格 + rn -> 重命名变量
    vim.keymap.set('n', '<leader>rn', function() vim.fn.VSCodeNotify('editor.action.rename') end)
    -- 映射：空格 + gd -> 跳转定义 (Go Definition)
    vim.keymap.set('n', '<leader>gd', function() vim.fn.VSCodeNotify('editor.action.revealDefinition') end)
    
else
    -- [[ 纯终端 Neovim 特有设置 ]]
    -- 当你直接在终端输 nvim 时，这些才会生效
    
    vim.opt.number = true           -- 显示行号
    vim.opt.ruler = true            -- 显示标尺
    vim.opt.syntax = "on"           -- 开启语法高亮
    vim.opt.background = "dark"     -- 背景色
    
    -- 你原来的 backspace 设置默认在 Neovim 里已经是这样了，不用特意写
end
