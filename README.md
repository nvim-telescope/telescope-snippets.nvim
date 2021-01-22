# telescope-snippets.nvim

Integration for [snippets.nvim](https://github.com/norcalli/snippets.nvim) with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

This plugin is also overriding `dap` internal ui, so running any `dap` command, which makes use of the internal ui, will result in a `telescope` prompt.

## Requirements

- [snippets.nvim](https://github.com/norcalli/snippets.nvim) (required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)

## Setup

You can setup the extension by doing

```lua
require('telescope').load_extension('snippets')
```

somewhere after your `require('telescope').setup()` call.

## Available functions

```lua
require'telescope'.extensions.snippets.snippets{}
```

or

```vim
:Telescope snippets snippets
```
