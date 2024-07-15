local has_plugin = require('userlib.runtime.utils').has_plugin

---@param opts {silent?:boolean}
return function(opts)
  opts = opts or {}
  local has_nui, Input = pcall(require, 'nui.input')
  local _, nui_autocmd = pcall(require, 'nui.utils.autocmd')
  local has_dispatch = has_plugin('vim-dispatch')

  local run_on_input = function(input)
    input = vim.trim(input or '')
    if input == '' then
      return
    end
    if has_dispatch then
      local dispatch_cmd_prefix = opts.silent and 'Dispatch!' or 'Dispatch'
      vim.cmd(dispatch_cmd_prefix .. ' ' .. input)
      return
    end
    vim.cmd('!' .. input)
  end

  if has_nui then
    local input = Input({
      position = '50%',
      size = {
        width = 60,
      },
      border = {
        style = 'single',
        text = {
          top = '  shell command',
          top_align = 'center',
        },
      },
      win_options = {
        winhighlight = 'Normal:Normal,FloatBorder:Normal',
      },
    }, {
      prompt = '',
      default_value = '',
      on_close = function() end,
      on_submit = function(value)
        run_on_input(value)
      end,
    })

    -- mount/open the component
    input:mount()

    -- unmount component when cursor leaves buffer
    input:on(nui_autocmd.event.BufLeave, function()
      input:unmount()
    end)

    input:map('n', '<Esc>', function()
      input:unmount()
    end, { noremap = true })
    input:map('i', '<Esc>', function()
      input:unmount()
    end, { noremap = true })
  else
    vim.ui.input({
      prompt = ' : ',
    }, function(input)
      run_on_input(input)
    end)
  end
end
