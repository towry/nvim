---@mod user-notes User notes
---@brief [[
--- * Doc for writting lemmy help: https://github.com/numToStr/lemmy-help/blob/master/emmylua.md
--- * Command to generate doc files: `make doc`
--- * Command to see this doc: `:h user-notes`
---@brief ]]

---@toc user-notes.contents

---@mod user-notes.pattern Pattern
---@mod user-notes.pattern.lookahead-and-lookbehind Lookahead and lookbehind
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

local M = {}
return M
