return {
	"goolord/alpha-nvim",
    version='*',
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "N > New File", "<cmd>ene<CR>"),
			dashboard.button("Leader ee", "T > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("Leader ff", "F > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("Leader fs", "W > Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("Leader wr", "R > Restore Session", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "Q > Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
