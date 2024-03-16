STYLUA=$$HOME/.local/share/nvim/mason/bin/stylua

all:
	echo "nothing to make"

format:
	$(STYLUA) lua/ after/ plugin/

.PHONY: format
