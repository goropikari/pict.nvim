# pict.nvim

A Neovim plugin that integrates with Microsoft's PICT (Pairwise Independent Combinatorial Testing) command-line tool.

This plugin allows you to generate combinatorial test cases using PICT and view the output directly within Neovim in various formats like Markdown or CSV. Optionally, you can also view the output in [VisiData](https://www.visidata.org/).

## Requirements

- [PICT command-line tool](https://github.com/microsoft/pict): Please ensure it is installed and accessible in your system's PATH.

### Optional: For VisiData Integration

- [VisiData](https://www.visidata.org/): Must be installed and accessible in your system's PATH.
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim): Required for displaying output in VisiData.

## Installation

You can install this plugin using your favorite plugin manager.

### lazy.nvim

```lua
{
  "goropikari/pict.nvim",
  -- The following dependency is optional, only needed for VisiData integration.
  dependencies = {
    { "akinsho/toggleterm.nvim", version = "*", config = true },
  },
  opts = {
    path = 'pict', -- default value
  },
}
```

## Usage

The plugin exposes several Lua functions that you can map to user commands.

- `require("pict").markdown()`: Generates test cases and displays them in a new buffer as a Markdown table.
- `require("pict").csv()`: Generates test cases and displays them in a new buffer in CSV format.
- `require("pict").visidata()`: Generates test cases and opens them in VisiData within a floating terminal. This requires `toggleterm.nvim` and `visidata` to be installed.

### Creating User Commands

To easily use these functions, you can create user commands in your Neovim configuration:

```lua
vim.api.nvim_create_user_command("PictMarkdown", require("pict").markdown, {})
vim.api.nvim_create_user_command("PictCsv", require("pict").csv, {})

-- Optional: for VisiData integration
vim.api.nvim_create_user_command("PictVisiData", require("pict").visidata, {})
```

With the commands above, you can open a model file and run `:PictMarkdown` to see the generated test cases as a Markdown table, or `:PictVisiData` to explore them interactively.
