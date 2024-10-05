local status, bufferline = pcall(require, "bufferline")
if not status then
	return
end

bufferline.setup({
	options = {
		diagnostic = "nvim_lsp",
		show_tab_indicators = true,
		show_buffer_close_icons = false,
		show_close_icon = false,
	},
})
