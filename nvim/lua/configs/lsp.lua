local status, nvim_lsp = pcall(require, "lspconfig")
if not status then
	return
end

local protocol = require("vim.lsp.protocol")

local on_attach = function(client, bufnr)
	-- format on save
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("Format", { clear = true }),
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = true })
			end,
		})
	end
end

local cmp_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_lsp_status then
	vim.notify("cmp_nvim_lsp not found", vim.log.levels.ERROR)
	return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

-- TypeScript
nvim_lsp.ts_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- CSS
nvim_lsp.cssls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- Tailwind
nvim_lsp.tailwindcss.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- HTML
nvim_lsp.html.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- JSON
nvim_lsp.jsonls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- Eslint
nvim_lsp.eslint.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- Python
nvim_lsp.pyright.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- Lua
nvim_lsp.luau_lsp.setup({})

-- sql
nvim_lsp.sqlls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- go
nvim_lsp.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

-- docker
nvim_lsp.dockerls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
