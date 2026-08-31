require("nvchad.configs.lspconfig").defaults()

vim.lsp.config["vtsls"] = {
    -- shouldn't do this, its only because our project doesn't have tsconfig in its packages, should just add one that extends root base
    root_dir = function(bufnr, on_dir)
        -- Prioritize markers that only exist at the absolute monorepo root
        local nx_monorepo_markers = {
            "nx.json",
            "tsconfig.base.json",
            ".git",
        }

        -- Fall back to local package markers if not in an Nx repo
        local local_markers = {
            "tsconfig.json",
            "package.json",
        }

        local project_root = vim.fs.root(bufnr, nx_monorepo_markers)
            or vim.fs.root(bufnr, local_markers)
            or vim.fn.getcwd()

        if project_root then
            on_dir(project_root)
        end
    end,
}

local servers = { "html", "cssls", "vtsls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
