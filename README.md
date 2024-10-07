
# cmp2lsp

Convert nvim-cmp sources to native LSP sources, allowing you to use your favorite nvim-cmp sources
with any completion engine. Native, mini-completion, care, coq, blink, whatever.

## Why?

I want to try out different completion engines without losing my beloved cmp sources.

I also see a bunch of new completion plugins writing the same code to hijack cmp sources, and
figured I could save them some time _and_ let mini-completion users in on the fun.

## Usage

It's important that this plugin loads before all of your cmp sources are registered, but that
`setup` is called after the sources are registered. This is a bit tricky. I've been using this:

```lua
{
  "benlubas/cmp2lsp",
  config = vim.schedule_wrap(function()
    require('cmp2lsp').setup({})
  end)
}
```

If you want to configure it, just look at `./lua/cmp2lsp/config.lua`, there's not much there right
now.

## Shout out

@max397574 I basically ~stole~ repurposed the entire `./lua/cmp/init.lua` file from `care.nvim`'s
[cmp-care](https://github.com/max397574/care-cmp/blob/main/lua/cmp/init.lua) plugin which hijacks
cmp sources for care.

@Saghen with [blink.cmp](https://github.com/Saghen/blink.cmp) the WIP plugin that made me want to
try out a new completion engine.

@jmbuhr with [quarto-nvim](https://github.com/quarto-dev/quarto-nvim) which does some similar
stuff creating a shim language server in Lua, which I used in
[neorg-interim-ls](https://github.com/benlubas/neorg-interim-ls), and now here as well!
