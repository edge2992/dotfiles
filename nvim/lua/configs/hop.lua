local status, hop = pcall(require, "hop")

if not status then
	return
end

hop.setup({
	keys = "etovxqdygblzhckisuran",
	jump_on_sole_occurrence = true,
	case_insensitive = true,
})
