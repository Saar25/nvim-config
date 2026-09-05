require "nvchad.mappings"

local map = vim.keymap.set

-- =======
-- General
-- =======

map("n", ";", ":", {
    desc = "CMD enter command mode",
})

map("i", "jk", "<ESC>")

map("n", "<leader>e", ':lua vim.diagnostic.open_float(0, {scope="line"})<CR>', {
    desc = "Show error",
})

map("n", "<leader>bd", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local all_bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(all_bufs) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            local name = vim.api.nvim_buf_get_name(buf)
            -- Check that it is not the current buffer and not nvim-tree
            if buf ~= current_buf and not name:match "NvimTree_" then
                vim.api.nvim_buf_delete(buf, { force = false })
            end
        end
    end
end, { desc = "Close all buffers except current" })

map("n", "<leader>bD", function()
    local all_bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(all_bufs) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            local name = vim.api.nvim_buf_get_name(buf)
            -- Check that it is not nvim-tree
            if not name:match "NvimTree_" then
                vim.api.nvim_buf_delete(buf, { force = false })
            end
        end
    end
end, { desc = "Close all buffers" })

-- ==========
-- Toggleterm
-- ==========

map({ "n", "t" }, "<leader>lg", function()
    require("configs.toggleterm").lazygit_terminal:toggle()
end, { desc = "Toggle Persistent Lazygit" })

map({ "n", "t" }, "<leader>ld", function()
    require("configs.toggleterm").lazydocker_terminal:toggle()
end, { desc = "Toggle Persistent Lazydocker" })

-- ========
-- Markdown
-- ========

map("n", "<leader>mp", ":MarkdownPreview<CR>", {
    desc = "Markdown Preview",
})

-- =====
-- Noice
-- =====

map("n", "<leader>ad", "<cmd>Noice dismiss<CR>", {
    desc = "noice dismiss",
    noremap = true,
    silent = true,
})

-- =========
-- Telescope
-- =========

map("n", "<leader>fR", "<cmd>Telescope resume<CR>", {
    desc = "telescope resume",
    noremap = true,
    silent = true,
})

map("n", "<leader>fr", "<cmd>Telescope lsp_references<CR>", {
    desc = "telescope find references",
    noremap = true,
    silent = true,
})

map("n", "<leader>fi", "<cmd>Telescope lsp_implementations<CR>", {
    desc = "telescope find implementations",
    noremap = true,
    silent = true,
})

local function get_visual_selection()
    local s_pos = vim.fn.getpos "v"
    local e_pos = vim.fn.getpos "."
    local lines = vim.fn.getregion(s_pos, e_pos, { mode = vim.fn.mode() })
    return table.concat(lines, "\n")
end

map({ "n", "x" }, "<leader>fW", function()
    local mode = vim.fn.mode()
    local opts = {}
    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_input "<esc>"
        opts.default_text = get_visual_selection()
    end
    require("telescope.builtin").live_grep(opts)
end, { desc = "Telescope Live Grep" })

map({ "n", "x" }, "<leader>fw", function()
    local mode = vim.fn.mode()
    local opts = {
        additional_args = function()
            return { "--fixed-strings" }
        end,
    }
    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_input "<esc>"
        opts.default_text = get_visual_selection()
    end
    require("telescope.builtin").live_grep(opts)
end, { desc = "Telescope Live Grep (Regex)" })

-- ==========
-- Treesitter
-- ==========

map("x", "v", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_parent(vim.v.count1)
    else
        vim.lsp.buf.selection_range(vim.v.count1)
    end
end, { desc = "Selection increment " })

map("x", "V", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_child(vim.v.count1)
    else
        vim.lsp.buf.selection_range(-vim.v.count1)
    end
end, { desc = "Selection decrement" })

-- =======
-- Conform
-- =======

map("n", "<leader>fm", function()
    -- 1. Format the file using conform
    require("conform").format({ lsp_fallback = true, async = false }, function(err)
        if err then
            return
        end

        -- 2. Clean up unused imports via LSP once formatting finishes
        vim.lsp.buf.code_action {
            context = {
                only = { "source.removeUnusedImports" },
            },
            apply = true,
        }
    end)
end, { desc = "Format file and remove unused imports" })

-- ================
-- Tiny Code Action
-- ================

vim.keymap.set({ "n", "x" }, "gra", function()
    require("tiny-code-action").code_action()
end, { noremap = true, silent = true })
