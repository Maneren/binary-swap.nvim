# Binary-Swap: swap operands in binary expressions

Small plugin for neovim 0.11+ powered by [treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
for swapping operands and operators in binary expressions:
`123 > 0` to `0 < 123` and `1 + 2` to `2 + 1`

- Comparison operations;
- Mathematical operations;

> [!NOTE]  
> This is a maintained fork of
> [binary-swap](https://github.com/Wansmer/binary-swap.nvim) following its
> archivation. So far almost all code logic is the same with only minor refactoring.

<https://user-images.githubusercontent.com/46977173/201508787-1b9604a1-1d0a-4feb-86d2-8b5417f4f679.mov>

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Maneren/binary-swap.nvim",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
  },
  opts = {},
  keys = {
    {
      "KEY",
      function ()
        require("binary-swap").swap_operands()
      end
    },
    {
      "KEY",
      function ()
        require("binary-swap").swap_operands_with_operator()
      end
    },
  }
}
```

With [packer.nvim](https://github.com/wbthomason/packer.nvim):

> [!WARNING]
> Not officially supported anymore

```lua
use({
  "Maneren/binary-swap.nvim",
  setup = function ()
    vim.keymap.set("n", "KEY", function ()
      require("binary-swap").swap_operands()
    end)
    vim.keymap.set("n", "KEY", function ()
      require("binary-swap").swap_operands_with_operator()
    end)
  end
})
```

## Usage

There are two methods available outside:

1. `require('binary-swap').swap_operands()` – swap only operands
   (e.g., `MAX_VALUE >= getCurrentValue()` will transform to
   `getCurrentValue() >= MAX_VALUE`; **operator** `>=` is not changed);

2. `require('binary-swap').swap_operands_with_operator()` – swap operands and
   operator to opposite if possible. (e.g., `MAX_VALUE >= getCurrentValue()`
   transforms to `getCurrentValue() <= MAX_VALUE`)

## Languages

Most languages have binary expression node with the type `binary_expression`, so
they should work out of the box. However, some languages may use different
node types, for example Python uses few `*_operator` node types. Those have to
be listed manually in the plugins, so they are being added when encountered.
Feel free to open an issue if your favorite language doesn't work.
