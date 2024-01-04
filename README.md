# Towry's meticulously crafted Neovim configuration

## Noteworthy Features

- Functions seamlessly without the reliance on plugins.
- Implements lazy loading of plugins.
- Excellently compatible with monorepo projects, providing efficient file and folder searching capabilities that automatically align with the project's current working directory.
- Enhanced workflow for opening folders and searching files, enabling additional actions to be performed on selected folders.
- Git keymaps for diff, log (file, etc.), blame (file, chunks), stage, and more.
- Optimized for use as a git mergetool, favoring a two-way merge approach.
- Reasonable buffer closing behavior, close buffer without surprise.

## Screenshots

<a href="https://github.com/towry/nvim/issues/26">checkout this issue for
screenshots</a>

## Commands

## Prerequisites

- [fzf](https://github.com/junegunn/fzf), For fuzzy searching and various kind
  of pickers
- [fd](https://github.com/sharkdp/fd), For find files/folders
- [rg](https://github.com/BurntSushi/ripgrep), For grep/searching
- [eza](https://github.com/eza-community/eza), For fzf preview

### `PrebundlePlugins`

Bundles all files within `user.plugins` into a single file named `user.plugins_bundle`.

## TODO

- [ ] Make lsp attach more controlable, for example, do not start lsp on large file.

## Special Thanks To

- https://github.com/LazyVim/LazyVim
- https://github.com/ecosse3/nvim
- https://github.com/glepnir/dope
- and others acknowledged within the code.
