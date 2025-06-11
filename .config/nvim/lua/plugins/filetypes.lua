return {
  -- no plugin to install, just config
  {
    -- use a dummy plugin as base, like 'nvim-lua/plenary.nvim' if needed
    "nvim-lua/plenary.nvim",
    config = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.j2", "*.jinja", "*.yaml.j2", "*.yml.j2" },
        callback = function()
          local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, 500, false), "\n")
          if lines:match("{{.-}}") or lines:match("{%%.-%%}") then
            vim.bo.filetype = "jinja"
          end
        end,
      })
    end,
    lazy = false,
  },
}
