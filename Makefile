.PHONY: lint lint-json

lint: lint-json

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
