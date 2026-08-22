return {
    {
        "stevearc/conform.nvim",
        -- event = "BufWritePre", -- uncomment for format on save
        opts = require "configs.conform",
        enabled = true,
    },
    {
        "tpope/vim-obsession",
    },
    {
        "mg979/vim-visual-multi",
        lazy = false,
        init = function()
            require "configs.visual-multi"
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            current_line_blame = true, -- Enables the core feature
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- Places blame at the end of the line
                delay = 100, -- Delay in milliseconds before blame shows
            },
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        opts = require "configs.tree",
    },
    {
        "christoomey/vim-tmux-navigator",
        event = "VeryLazy",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        opts = require "configs.telescope",
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        build = ":TSUpdate | TSInstallAll",
        opts = require "configs.treesitter",
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
        opts = require "configs.autotag",
        config = true,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- or nvim-web-devicons
        ft = { "markdown" },
        config = function()
            require("render-markdown").setup {}
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_browser = "google-chrome"
        end,
        ft = { "markdown" },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
    },
    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("auto-session").setup {
                log_level = "error",
                auto_session_enable_cmd_pre_hook = false,
            }
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        lazy = false,
        config = function()
            require "configs.toggleterm"
        end,
    },
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            -- optional picker via telescope
            { "nvim-telescope/telescope.nvim" },
        },
        event = "LspAttach",
        opts = {
            picker = "telescope",
        },
    },
}
