return {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        'WhoIsSethDaniel/mason-tool-installer',
    },
  config = function()
    local mason_lspconfig      = require('mason-lspconfig')
    local mason_tool_installer = require('mason-tool-installer')

    mason_tool_installer.setup({
      ensure_installed = {
        'prettier', -- prettier formatter
        'stylua',   -- lua formatter
        'isort',    -- python formatter
        'ruff',     -- linter
      },
    })
  end,
}
