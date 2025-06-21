if vim.g.loaded_deej then
	return
end
vim.g.loaded_deej = 1

require("deej").setup()
