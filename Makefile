all:
	echo "nothing to make"

format:
	env stylua lua/ after/ plugin/

.PHONY: format
