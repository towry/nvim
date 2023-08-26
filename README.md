# Towry's hand crafted NeoVim config

## Features

- Works without plugins.
- Lazy load plugins.
- Works well with monorepo projects (Search files, folders etc).

## Screenshots

<details><summary><h4>Jump to line with ONLY two keyboard press</h4></summary>
<img width="1101" alt="截屏2023-08-21 17 10 16" src="https://github.com/towry/nvim/assets/8279858/c4eade65-56af-40da-95de-5ea7e234c3fc">
</details> 
<details><summary><h4>Recent files</h4></summary>
<img width="923" alt="截屏2023-08-21 17 09 45" src="https://github.com/towry/nvim/assets/8279858/c8226216-331c-4a0a-b087-f644ec155ff5">
</details> 
<details><summary><h4>Dashboard with quick jump</h4></summary>
<p>
<img width="833" alt="截屏2023-08-21 17 09 32" src="https://github.com/towry/nvim/assets/8279858/f7238fb5-0799-45ee-9d10-61e1068fcfd0">
</p>
</details> 
<details><summary><h4>File browser with extended actions</h4></summary>
<img width="998" alt="截屏2023-08-21 17 11 01" src="https://github.com/towry/nvim/assets/8279858/fa8fa272-9c48-4ba3-933e-27e26adb5ffa">
</details>

## TODO

- [ ] Improve format.
- [ ] Remeber last edited window and buffer.
- [ ] refactor the `userlib.ui.dropdown` to use telescope-ui-select extension.
- [ ] fix lsp keymaps binding.
- [ ] setup a health check.

## Commands

### `PrebundlePlugins`

will bundle all files inside `user.plugins` to a single file `user.plugins_bundle`

## FYI

- If there is something wrong with treesitter, try run `TSUpdate`.

## Big thanks to

- https://github.com/LazyVim/LazyVim
- https://github.com/ecosse3/nvim
- https://github.com/glepnir/dope
- others mentioned in the code.
