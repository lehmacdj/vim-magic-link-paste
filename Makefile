.PHONY: test

test:
	nvim --headless -u NONE \
	  --cmd 'set shada="NONE"' \
	  -S test/test_markdown.vim
