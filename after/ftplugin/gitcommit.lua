local bufnr = vim.api.nvim_get_current_buf()
local libutils = require('userlib.runtime.utils')
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<cmd>q<cr>', { silent = true, nowait = true, noremap = true })
vim.b[0].autoformat_disable = true

local use_rpc = true
local last_task_mark = nil
local task_id = 0

local function reset_buffer()
  if last_task_mark ~= nil then
    local end_row = last_task_mark:end_pos().row - 1
    if end_row <= 0 then
      end_row = 1
    end
    vim.api.nvim_buf_set_lines(bufnr, last_task_mark:start_pos().row, end_row, false, {})
    last_task_mark = nil
  end
end

local function apply_suggestion(prompt_text, tid)
  if not prompt_text or #prompt_text <= 0 then
    vim.notify("No git diff content found", vim.log.levels.ERROR)
    return
  end

  reset_buffer()

  local snippet = string.format(
    [[
You are a git expert and experienced programmer.
1. Do not contains any information that do not belong to a git commit message.\n
2. Do not explain how you generate the response.\n
3. Follow conventional commits standard.\n
3. please formulate a concise git commit message summarizing the key changes based on current context and the following git diff output:\n
```diff\n%s```
    ]],
    prompt_text)
  local rpc = require('sg.cody.rpc')
  local Mark = require('sg.mark')
  local mark = Mark.init({
    ns = bufnr,
    bufnr = bufnr,
    start_row = 0,
    start_col = 0,
    end_row = 1,
    end_col = 0,
  })
  last_task_mark = mark
  local text = ""
  local ns = vim.api.nvim_create_namespace('sg.cody.gitcommit')
  local function apply(suggestion)
    if tid ~= task_id then return end
    local lines = vim.split(suggestion, '\n')
    -- iterate the lines, if vim.trim(line) is ```, ignore it
    local new_lines = {}
    for _, line in ipairs(lines) do
      if vim.trim(line) ~= '```' then
        table.insert(new_lines, line)
      end
    end
    vim.api.nvim_buf_set_lines(bufnr, mark:start_pos().row, mark:end_pos().row, false, new_lines)
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {
    virt_text = { { 'Thinking ...', 'Comment' } },
    virt_text_pos = 'eol',
    virt_text_hide = false,
  })

  rpc.execute.code_question(snippet, function(res)
    text = res.text .. '\n'
    last_task_id = res.data.id
    if res and res.text and ns ~= nil then
      -- clear the ghost text
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
    apply(text)
  end)
end

local function write_message_()
  task_id = task_id + 1
  local tid = task_id
  local on_exit = vim.schedule_wrap(function(obj)
    if task_id ~= tid then return end
    if obj.code ~= 0 then
      vim.notify('Failed to get Git status', vim.log.levels.ERROR)
      return
    end
    if use_rpc then
      return apply_suggestion(obj.stdout, tid)
    end
    -- split new lines to table
    local content = vim.split(obj.stdout, '\n')
    local diffbufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(diffbufnr, 0, -1, false, content)
    vim.api.nvim_set_option_value('filetype', 'diff', {
      buf = diffbufnr,
    })
    vim.api.nvim_set_option_value('buftype', 'nofile', {
      buf = diffbufnr,
    })
    vim.api.nvim_set_option_value('bufhidden', 'hide', {
      buf = diffbufnr,
    })
    local sg_cmd = require('sg.cody.commands')
    local task = sg_cmd.do_task(diffbufnr, 0, vim.api.nvim_buf_line_count(diffbufnr),
      "Write git commit message for current context with format")
    local taskbufnr = task.layout.history.bufnr
    set('n', '<cr>', function()
      vim.api.nvim_buf_set_lines(bufnr,
        0,
        1,
        false,
        vim.api.nvim_buf_get_lines(taskbufnr, 0, -1, false))
      task.layout:hide()
    end, {
      desc = 'Accept',
      noremap = true,
    })
  end)
  -- must force start, otherwise on the second time, it will not work.
  vim.notify('start cody client')
  require('sg.cody.rpc').start({ force = true }, function()
    vim.system({
      'git',
      'diff',
      '--staged',
      '--unified=0',
    }, {
      text = true,
      cwd = vim.cfg.runtime__starts_cwd,
    }, on_exit)
  end)
end

--- rpc not working on the second time, the response doesn't contain the current
--- buffer's content as context.
local function setup_cody()
  if not libutils.has_plugin('sg.nvim') then return end

  set({ 'i', 'n' }, '<localleader>ac', function()
    write_message_()
  end, {
    desc = 'Write git commit message with AI',
    noremap = true,
  })

  vim.api.nvim_buf_create_user_command(0, 'WriteGitCommitMessage', write_message_, {
    desc = 'Write git commit with AI',
  })
end

setup_cody()
