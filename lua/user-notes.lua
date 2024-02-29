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

---@mod user-notes.diff-current-buffer-with-fugitive Diff current buffer with
---fugitive
---@brief [[
---我们想要查看当前文件和某个commit下此文件之间的变动
---
---Steps:
--- 1. 获取你想要查看的 commit，通过 fugtive 导航到此文件在某 commit
--- 下的状态。
--- 2. 你可以获取到当前 fugtive buffer 的名字，bufnr等.
--- 3. 在当前文件中运行命令 `:exec "diffsplit" bufname(bufnr_of_fugitive_buf)`.
---@brief ]]

local M = {}
return M
