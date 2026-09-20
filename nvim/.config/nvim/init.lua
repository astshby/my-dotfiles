-- ============================================================
-- 基础配置
-- ============================================================

vim.g.mapleader = " "

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.hidden = true
vim.opt.clipboard = "unnamedplus"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

vim.opt.undofile = true


-- ============================================================
-- 独立 Neovim
-- ============================================================

if not vim.g.vscode then
    vim.opt.number = true
    vim.opt.ruler = true
    vim.opt.mouse = "a"
    vim.opt.termguicolors = true
end


-- ============================================================
-- 平台判断
-- ============================================================

local is_windows = vim.fn.has("win32") == 1

local uname = vim.uv.os_uname()
local release = (uname.release or ""):lower()

local is_wsl =
    not is_windows
    and release:find("microsoft", 1, true) ~= nil


-- ============================================================
-- 命令工具
-- ============================================================

local function run_sync(args)
    local ok, proc = pcall(vim.system, args, {
        text = true,
    })

    if not ok then
        return nil
    end

    local result = proc:wait(500)

    if result.code ~= 0 then
        return nil
    end

    return vim.trim(result.stdout or "")
end


local function run_async(args)
    pcall(function()
        vim.system(args, {
            text = true,
        })
    end)
end


-- ============================================================
-- 输入法
--
-- Windows / WSL：
--     AIMSwitcher
--
-- Linux VM：
--     fcitx5-remote
--
-- 目标：
--     Insert -> Normal：自动英文
--     Normal -> Insert：恢复之前输入状态
-- ============================================================

local ime_backend = nil
local ime_previous = nil


local function detect_ime_backend()
    -- Windows 与 WSL 优先控制 Microsoft 拼音
    if (is_windows or is_wsl)
        and vim.fn.executable("AIMSwitcher.exe") == 1
    then
        return "aim"
    end

    -- 原生 Linux 使用 Fcitx5
    if vim.fn.executable("fcitx5-remote") == 1 then
        return "fcitx5"
    end

    return nil
end


ime_backend = detect_ime_backend()


local function ime_leave_insert()
    if ime_backend == "aim" then
        -- 保存 Microsoft 拼音当前模式
        ime_previous =
            run_sync({ "AIMSwitcher.exe", "--imm" })

        -- 强制英文
        run_async({
            "AIMSwitcher.exe",
            "--imm",
            "0",
        })

        return
    end

    if ime_backend == "fcitx5" then
        -- 0=关闭，1=inactive，2=active
        ime_previous =
            run_sync({ "fcitx5-remote" })

        if ime_previous == "2" then
            run_async({
                "fcitx5-remote",
                "-c",
            })
        end
    end
end


local function ime_enter_insert()
    if ime_backend == "aim" then
        local state = tonumber(ime_previous)

        -- 之前不是英文时恢复
        if state and state ~= 0 then
            run_async({
                "AIMSwitcher.exe",
                "--imm",
                tostring(state),
            })
        end

        return
    end

    if ime_backend == "fcitx5" then
        -- 之前为 active 才恢复
        if ime_previous == "2" then
            run_async({
                "fcitx5-remote",
                "-o",
            })
        end
    end
end


local function ime_force_english()
    if ime_backend == "aim" then
        run_async({
            "AIMSwitcher.exe",
            "--imm",
            "0",
        })

        return
    end

    if ime_backend == "fcitx5" then
        run_async({
            "fcitx5-remote",
            "-c",
        })
    end
end


local ime_group =
    vim.api.nvim_create_augroup(
        "AutoInputMethod",
        { clear = true }
    )


vim.api.nvim_create_autocmd(
    "InsertLeave",
    {
        group = ime_group,
        callback = ime_leave_insert,
    }
)


vim.api.nvim_create_autocmd(
    "InsertEnter",
    {
        group = ime_group,
        callback = ime_enter_insert,
    }
)


vim.api.nvim_create_autocmd(
    "VimEnter",
    {
        group = ime_group,
        callback = ime_force_english,
    }
)


vim.api.nvim_create_autocmd(
    "FocusGained",
    {
        group = ime_group,

        callback = function()
            if vim.fn.mode():sub(1, 1) ~= "i" then
                ime_force_english()
            end
        end,
    }
)


-- ============================================================
-- VSCode Neovim
-- ============================================================

if vim.g.vscode then
    local vscode = require("vscode")

    -- 重命名
    vim.keymap.set(
        "n",
        "<leader>rn",

        function()
            vscode.action(
                "editor.action.rename"
            )
        end,

        {
            silent = true,
            desc = "重命名",
        }
    )


    -- 跳转定义
    vim.keymap.set(
        "n",
        "<leader>gd",

        function()
            vscode.action(
                "editor.action.revealDefinition"
            )
        end,

        {
            silent = true,
            desc = "跳转定义",
        }
    )


    -- 文档统一预览
    vim.keymap.set(
        "n",
        "<leader>p",

        function()
            local ext =
                vim.fn.expand("%:e"):lower()

            if ext == "md" then
                vscode.action(
                    "markdown.showPreviewToSide"
                )

            elseif ext == "typ" then
                vscode.action(
                    "typst-preview.preview"
                )

            elseif ext == "tex" then
                vscode.action(
                    "latex-workshop.view"
                )
            end
        end,

        {
            silent = true,
            desc = "预览文档",
        }
    )


    -- LaTeX 编译
    vim.keymap.set(
        "n",
        "<leader>b",

        function()
            local ext =
                vim.fn.expand("%:e"):lower()

            if ext == "tex" then
                vscode.action(
                    "latex-workshop.build"
                )
            end
        end,

        {
            silent = true,
            desc = "编译 LaTeX",
        }
    )
end
