return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()  -- loads friendly-snippets
    require("luasnip.loaders.from_lua").load({
      paths = { "~/.config/nvim/lua/snippets" }
    })
  end,
}
