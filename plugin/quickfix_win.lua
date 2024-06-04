-- 1. open a below term
-- 2. <C-w>B to close below term window.
do
  if vim.g.quickfix_win_loaded == 1 then
    return
  end
  vim.g.quickfix_win_loaded = 1
end

---@param opts {height:number,width: number,exclude_bufnr?:number,vertical:boolean,split:'left'|'right'|'above'|'below'}
local function create_window_at_top_and_focus(opts)
  local exclude_bufnr = opts.exclude_bufnr
  local vertical = opts.vertical
  -- local split = opts.split

  local bufnr = require('userlib.runtime.buffer').next_bufnr()
  if bufnr == exclude_bufnr then
    bufnr = nil
  end

  Ty.resize.block()
  vim.cmd(('%srightbelow %s'):format(vertical and 'vert ' or 'hor ', bufnr and ('sb ' .. bufnr) or 'new'))
  Ty.resize.after_open()

  vim.schedule(function()
    if not opts.height or opts.vertical then
      return
    end
    vim.cmd('resize ' .. opts.height)
    Ty.resize.record()
  end)
end

-- prevent quickfix or location list special window become the last window.
vim.api.nvim_create_augroup('quickfix_win', { clear = true })
vim.api.nvim_create_autocmd('WinClosed', {
  group = 'quickfix_win',
  callback = function(ctx)
    local curwin = tonumber(ctx.match)
    if not curwin or vim.api.nvim_win_get_config(curwin).relative ~= '' then
      return
    end

    local curwin_config = vim.api.nvim_win_get_config(curwin)
    local curwin_height = vim.api.nvim_win_get_height(curwin)
    local curwin_width = vim.api.nvim_win_get_width(curwin)

    -- list windows in current tab
    local wc = vim.api.nvim_tabpage_list_wins(0)
    local wc_excluded_float_win = vim.tbl_filter(function(win)
      local is_float = vim.api.nvim_win_get_config(win).relative ~= ''
      if is_float then
        return false
      end
      return true
    end, wc)

    local lastwin = nil
    local wincount = 0
    for _, win in ipairs(wc_excluded_float_win) do
      if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = win }) then
        wincount = wincount + 1
      elseif win == curwin then
        -- pass
      else
        local current_win_bufnr = vim.api.nvim_win_get_buf(win)
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = current_win_bufnr })
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = current_win_bufnr })

        local is_special_win = buftype ~= ''
          and not vim.tbl_contains({ 'terminal' }, buftype)
          and not vim.tbl_contains({ 'oil' }, filetype)
        if not is_special_win then
          lastwin = win
          break
        end
        wincount = wincount + 1
      end
    end

    if lastwin then
      return
    end
    -- no normal buffer window and still window left, create empty window and
    -- focus, otherwise, do nothing.
    if wincount == 0 then
      return
    end

    Ty.resize.record()
    -- check lastwin is quickfix or location list or it's buffer type is special
    create_window_at_top_and_focus({
      split = curwin_config.split or 'above',
      width = curwin_width,
      height = curwin_height,
      vertical = curwin_config.vertical,
      exclude_bufnr = tonumber(ctx.buf),
    })
    vim.notify('No special window become last', vim.log.levels.INFO)
  end,
})
