# User notes

## Lookahead and lookbehind

refs:

- https://vim.fandom.com/wiki/Regex_lookahead_and_lookbehind

在搜索或者替换中，可以使用 lookahead /or lookbehind 辅助查找.
比如如下内容:

`"package-name": "0.0.1-tag-123242"`

我们想要替换版本号内容为 `workspace:*`，我们可以使用如下命令:

`:s/:\s"\zs.\+\ze"/workspace:*`

其中，`\zs` 表示前面的都不参与匹配结果, `\ze` 表示后面都不参与匹配结果。

## Diff current buffer with fugitive

我们想要查看当前文件和某个commit下此文件之间的变动

### 方法1. 在 _fugitive-object_ 中:

1.  通过 fugtive (_:Git_) 导航到此文件在某 commit 下的 _fugitive_ 历史文件。
2.  你可以获取到 _fugitive_ 历史文件的名字，_bufnr_ (我们记做123).
3.  在当前文件中运行命令 `:exec "diffsplit" bufname(123)`.

### 方法2. 在 _:Git_blame_ 中:

1.  你可以通过 Git blame 当前文件，查找到当前文件相关行的改动。
2.  在 blame view 中，你能看到相关行的 <commit-hash>。
3.  在当前文件中运行 `Gdiffsplit <commit-hash>` ，可以进行当前文件的diff。
4.  如果 3 中的操作你发现没有变动，说明 <commit-hash> 可能是最新的，请看"步骤5".
5.  或者运行 `Gdiffsplit <commit-hash^1>`，来查看当前文件和 <commit-hash> 前的变动。

## Align block of text

Example text:

```
line 1   = 1
line 123   = 3
line 1234 = 5
```

Suppose we want to left align `=` to make it like:

```
line 1    = 1
line 123  = 3
line 1234 = 5
```

1. Select the lines.
2. Run in cmd: `:'<,'>normal f=9i `, note there is a space after `9i`, we want
   to insert as many spaces, you can change 9 to 20 or 200.
3. Now, go to the first line of the block then move cursor to the column that we
   want the `=` to align to.
4. Use `<C-v>` to start visual select, move cursor down to the last line of the
   text block. press `$` to select to the end, now you have lines that is visual
   selected.
5. press `9<` to left shift in motion, done.