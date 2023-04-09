# neovim config

Approach:

- 1 file per plugin w/ co-located key mappings makes for easy deletion.
- Try to push as much as possible into those files while recognizing that some things need to be shared (e.g. `on_attach` for lsp)
- Name the plugin file after the plugin name except where the concept is more important (e.g. `colorscheme.lua`)
- Some of this will be entirely JustForMe™ and that's fine.
