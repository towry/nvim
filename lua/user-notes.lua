-- vim:nowrap:
---@mod user-notes User notes
---@brief [[
--- * Doc for writting lemmy help: https://github.com/numToStr/lemmy-help/blob/master/emmylua.md
--- * Command to generate doc files: `make doc`
--- * Command to see this doc: `:h user-notes`
---@brief ]]

---@toc user-notes.contents

---@mod user-notes.pattern-lookahead-n-lookbehind Lookahead and lookbehind
---@brief [[
---refs ~
---- https://vim.fandom.com/wiki/Regex_lookahead_and_lookbehind
---
---在搜索或者替换中，可以使用 lookahead /or lookbehind 辅助查找.
---比如如下内容:
--->
---"package-name": "0.0.1-tag-123242"
---<
---我们想要替换版本号内容为 `workspace:*`，我们可以使用如下命令:
--->
---:s/:\s"\zs.\+\ze"/workspace:*
---<
---其中，`\zs` 表示前面的都不参与匹配结果, `\ze` 表示后面都不参与匹配结果。
---@brief ]]

---@mod user-notes.diff-current-buffer-with-fugitive Diff current buffer with fugitive
---
---@brief [[
---我们想要查看当前文件和某个commit下此文件之间的变动
---
--- 方法1. 在 *fugitive-object* 中:
---
--- 1. 通过 fugtive (*:Git*) 导航到此文件在某 commit 下的 *fugitive* 历史文件。
--- 2. 你可以获取到 *fugitive* 历史文件的名字，*bufnr* (我们记做123).
--- 3. 在当前文件中运行命令 `:exec "diffsplit" bufname(123)`.
---
--- 方法2. 在 *:Git_blame* 中:
---
--- 1. 你可以通过 Git blame 当前文件，查找到当前文件相关行的改动。
--- 2. 在 blame view 中，你能看到相关行的 <commit-hash>。
--- 3. 在当前文件中运行 `Gdiffsplit <commit-hash>` ，可以进行当前文件的diff。
--- 4. 如果 3 中的操作你发现没有变动，说明 <commit-hash> 可能是最新的，请看"步骤5".
--- 5. 或者运行 `Gdiffsplit <commit-hash^1>`，来查看当前文件和 <commit-hash> 前的变动。
---
---@brief ]]

local M = {}
return M
