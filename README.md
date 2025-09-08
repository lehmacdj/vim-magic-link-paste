# vim-magic-link-paste
Easily create links when pasting URLs. When pasting a URL over text in visual mode, instead of replacing that text, links that text to the pasted URL.

## Installation
Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'lehmacdj/vim-magic-link-paste'
```

## Quick start
Copy a link, e.g. `https://unformeddelta.wiki` and then open any markdown file. Visually select some text:
```markdown
- vim-magic-link-paste: easily create links when pasting URLs
  ^^^^^^^^^^^^^^^^^^^^
  Select this!
```

Then paste, resulting in the following buffer:
```markdown
- [vim-magic-link-paste](https://github.com/lehmacdj/vim-magic-link-paste): easily create links when pasting URLs
```

See `:h magic-link-paste` for more details.
