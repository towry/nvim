STYLUA=$$HOME/.local/share/nvim/mason/bin/stylua

all:
	echo "nothing to make"

doc:
	lemmy-help ./lua/user-notes.lua > doc/user_notes.txt && nvim --headless +"helptags doc" +"qa"

format:
	$(STYLUA) lua/ after/ plugin/

.PHONY: doc format
