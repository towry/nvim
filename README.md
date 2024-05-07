# Towry's Neovim configuration

## Noteworthy Features

- Functions seamlessly without the reliance on plugins.
- Implements lazy loading of plugins.
- Excellently compatible with monorepo projects, providing efficient file and folder searching capabilities that automatically align with the project's current working directory.
- Enhanced workflow for opening folders and searching files, enabling additional actions to be performed on selected folders.
- Git keymaps for diff, log (file, etc.), blame (file, chunks), stage, and more.
- Optimized for use as a git mergetool, favoring a two-way merge approach.
- Zoxide support and change cwd from terminal buffer

## Screenshots

<table>
  <tr>
    <td>Dark</td>
    <td>Light</td>
  </tr>
  <tr>
    <td>
      <img width="961"  src="https://github.com/towry/nvim/assets/8279858/b19f9430-e537-4b37-93a0-9751ff024253" alt="dark">
    </td>
<td>
  <img width="961" alt="light" src="https://github.com/towry/nvim/assets/8279858/6395ef3d-38cf-4b3b-849f-9b988c424234"></td>
  </tr>
</table>
<table>
  <tr><td>Git(logs, mergetool)</td></tr>
    <tr>
    <td>
      <img width="100%" alt="diff" src="https://github.com/towry/nvim/assets/8279858/ff35a13c-bbbb-4ae9-b524-7c4b06fc4aaf"></td>
  </tr>
  <tr>
    <td>
      <img width="1376" alt="Neovim as git merge tool" src="https://github.com/towry/nvim/assets/8279858/aecf849d-9f82-4c9a-acf5-c2eff61fa43e">
  </tr>
</table>

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

- [x] Make lsp attach more controlable, for example, do not start lsp on large file.
- [ ] TODO: fix project nvim not working well in nowrite buffers.

## Special Thanks To

- https://github.com/LazyVim/LazyVim
- https://github.com/ecosse3/nvim
- https://github.com/glepnir/dope
- and others acknowledged within the code.
