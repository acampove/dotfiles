return {
	"NeogitOrg/neogit",
    version = '*',
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration

		-- Only one of these is needed.
		"nvim-telescope/telescope.nvim", -- optional
		"ibhagwan/fzf-lua", -- optional
		"echasnovski/mini.pick", -- optional
	},
	config = function ()
        require("neogit").setup(
            {
                commit_editor={
                    kind="replace"
                }
            })
	end,
}
