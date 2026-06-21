.PHONY: lint lint-json nvim-check

lint: lint-json

NVIM_SRC := private_dot_config/nvim
STYLUA := $(shell command -v stylua 2>/dev/null || echo $(HOME)/.local/share/nvim/mason/bin/stylua)

nvim-check:
	@echo "==> stylua format check"
	@if [ -x "$(STYLUA)" ]; then \
		"$(STYLUA)" --check $(NVIM_SRC); \
	else \
		echo "  stylua binary not found; falling back to pre-commit"; \
		pre-commit run stylua --files $(NVIM_SRC)/init.lua $$(find $(NVIM_SRC)/lua -name '*.lua'); \
	fi
	@echo "==> headless syntax + core load check"
	@NVIM_SRC="$(CURDIR)/$(NVIM_SRC)" nvim --headless --clean \
		--cmd "set rtp^=$(CURDIR)/$(NVIM_SRC)" \
		+"luafile scripts/nvim-check.lua" +qa

lint-json:
	@echo "Validating JSON files..."
	@fail=0; \
	for f in $$(find . -name '*.json' -not -path './.git/*'); do \
		if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$$f" 2>/dev/null; then \
			echo "  OK: $$f"; \
		else \
			echo "  FAIL: $$f"; \
			fail=1; \
		fi; \
	done; \
	[ $$fail -eq 0 ] && echo "All JSON files valid." || (echo "JSON validation failed." && exit 1)
