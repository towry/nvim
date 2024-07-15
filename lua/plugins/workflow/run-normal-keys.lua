return function()
  local has_nui, Input = pcall(require, 'nui.input')
  local _, nui_autocmd = pcall(require, 'nui.utils.autocmd')

  local run_on_input = function(input)
    input = string.gsub(vim.trim(input or ''), '%s*', '')
    if input == '' then
      return
    end
    local key = vim.api.nvim_replace_termcodes(input, true, false, true)
    vim.api.nvim_feedkeys(key, 'n', false)
  end

  if has_nui then
    local input = Input({
      position = '50%',
      size = {
        width = 40,
      },
      border = {
        style = 'single',
        text = {
          top = '  Normal keys',
          top_align = 'center',
        },
      },
      win_options = {
        winhighlight = 'Normal:Normal,FloatBorder:Normal',
      },
    }, {
      prompt = '> ',
      keymap = {
        close = { '<Esc>', '<C-c>' },
      },
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
      prompt = '   normal keys: ',
      completion = 'mapping',
    }, function(input)
      run_on_input(input)
    end)
  end
end
