local core = require('fzf-lua.core')
local path = require('fzf-lua.path')
local utils = require('fzf-lua.utils')
local shell = require('fzf-lua.shell')
local config = require('fzf-lua.config')
local devicons = require('fzf-lua.devicons')

local M = {}

local filter_buffers = function(opts, unfiltered)
  if type(unfiltered) == 'function' then
    unfiltered = unfiltered()
  end

  local curtab_bufnrs = {}
  if opts.current_tab_only then
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(core.CTX().tabh)) do
      local b = vim.api.nvim_win_get_buf(w)
      curtab_bufnrs[b] = true
    end
  end

  local excluded, max_bufnr = {}, 0
  local bufnrs = vim.tbl_filter(function(b)
    if not vim.api.nvim_buf_is_valid(b) then
      excluded[b] = true
    elseif not opts.show_unlisted and b ~= core.CTX().bufnr and vim.fn.buflisted(b) ~= 1 then
      excluded[b] = true
    elseif not opts.show_unloaded and not vim.api.nvim_buf_is_loaded(b) then
      excluded[b] = true
    elseif opts.ignore_current_buffer and b == core.CTX().bufnr then
      excluded[b] = true
    elseif opts.current_tab_only and not curtab_bufnrs[b] then
      excluded[b] = true
    elseif opts.no_term_buffers and utils.is_term_buffer(b) then
      excluded[b] = true
    elseif opts.cwd_only and not path.is_relative_to(vim.api.nvim_buf_get_name(b), vim.loop.cwd()) then
      excluded[b] = true
    elseif opts.cwd and not path.is_relative_to(vim.api.nvim_buf_get_name(b), opts.cwd) then
      excluded[b] = true
    end
    if utils.buf_is_qf(b) then
      if opts.show_quickfix then
        -- show_quickfix trumps show_unlisted
        excluded[b] = nil
      else
        excluded[b] = true
      end
    end
    if not excluded[b] and b > max_bufnr then
      max_bufnr = b
    end
    return not excluded[b]
  end, unfiltered)

  return bufnrs, excluded, max_bufnr
end

local populate_buffer_entries = function(opts, bufnrs, tabh)
  local buffers = {}
  for _, bufnr in ipairs(bufnrs) do
    local flag = (bufnr == core.CTX().bufnr and '%') or (bufnr == core.CTX().alt_bufnr and '#') or ' '

    local element = {
      bufnr = bufnr,
      flag = flag,
      info = utils.getbufinfo(bufnr),
      readonly = vim.bo[bufnr].readonly,
    }

    -- Get the name for missing/quickfix/location list buffers
    -- NOTE: we get it here due to `gen_buffer_entry` called within a fast event
    if not element.info.name or #element.info.name == 0 then
      element.info.name = utils.nvim_buf_get_name(element.bufnr, element.info)
    end

    -- get the correct lnum for tabbed buffers
    if tabh then
      local winid = utils.winid_from_tabh(tabh, bufnr)
      if winid then
        element.info.lnum = vim.api.nvim_win_get_cursor(winid)[1]
      end
    end

    table.insert(buffers, element)
  end
  if opts.sort_lastused then
    -- switching buffers and opening 'buffers' in quick succession
    -- can lead to incorrect sort as 'lastused' isn't updated fast
    -- enough (neovim bug?), this makes sure the current buffer is
    -- always on top (#646)
    -- Hopefully this gets solved before the year 2100
    -- DON'T FORCE ME TO UPDATE THIS HACK NEOVIM LOL
    local future = os.time({ year = 2100, month = 1, day = 1, hour = 0, minute = 00 })
    local get_unixtime = function(buf)
      if buf.flag == '%' then
        return future
      elseif buf.flag == '#' then
        return future - 1
      else
        return buf.info.lastused
      end
    end
    table.sort(buffers, function(a, b)
      return get_unixtime(a) > get_unixtime(b)
    end)
  end
  return buffers
end

local function gen_buffer_entry(opts, buf, max_bufnr, cwd)
  -- local hidden = buf.info.hidden == 1 and 'h' or 'a'
  local hidden = ''
  local readonly = buf.readonly and '=' or ' '
  local changed = buf.info.changed == 1 and '+' or ' '
  local flags = hidden .. readonly .. changed
  local leftbr = '['
  local rightbr = ']'
  local bufname = #buf.info.name > 0 and path.relative_to(buf.info.name, cwd or vim.loop.cwd())
  local entryname = ''
  if opts.filename_only then
    bufname = path.basename(bufname)
  elseif opts.filename_first then
    bufname = path.HOME_to_tilde(bufname)
    -- vscode like display
    local basename = path.basename(bufname)
    entryname = basename
    ---@diagnostic disable-next-line: cast-local-type
    bufname = path.parent(bufname, false) or ''
  else
    -- replace $HOME with '~' for paths outside of cwd
    bufname = path.HOME_to_tilde(bufname)
    if opts.path_shorten and not bufname:match('^%a+://') then
      bufname = path.shorten(bufname, tonumber(opts.path_shorten))
    end
  end

  if bufname and bufname ~= '' then
    if opts.show_lnum then
      -- add line number
      ---@diagnostic disable-next-line: cast-local-type
      bufname = ('%s :%s'):format(bufname, buf.info.lnum > 0 and buf.info.lnum or '')
    end
    if opts.filename_first then
      bufname = utils.ansi_codes.grey(bufname)
    end
  end
  if buf.flag == '%' then
    flags = utils.ansi_codes[opts.hls.buf_flag_cur](buf.flag) .. flags
  elseif buf.flag == '#' then
    flags = utils.ansi_codes[opts.hls.buf_flag_alt](buf.flag) .. flags
  else
    flags = utils.nbsp .. flags
  end
  local bufnrstr = string.format('%s%s%s', leftbr, utils.ansi_codes[opts.hls.buf_nr](tostring(buf.bufnr)), rightbr)
  local buficon = ''
  local hl = ''
  if opts.file_icons then
    buficon, hl = devicons.get_devicon(
      buf.info.name,
      -- shell-like icon for terminal buffers
      utils.is_term_bufname(buf.info.name) and 'sh' or nil
    )
    if hl and opts.color_icons and buficon ~= '' then
      buficon = utils.ansi_from_rgb(hl, buficon)
    end
  end
  local max_bufnr_w = 3 + #tostring(max_bufnr) + utils.ansi_escseq_len(bufnrstr)
  local item_str = string.format(
    '%s%s%s%s%s%s%s%s%s%s',
    utils._if(opts._prefix, opts._prefix, ''),
    string.format('%-' .. tostring(max_bufnr_w) .. 's', bufnrstr),
    utils.nbsp,
    flags,
    buficon ~= '' and utils.nbsp or '',
    buficon,
    entryname ~= '' and utils.nbsp or '',
    entryname ~= '' and (entryname .. ' ') or '',
    utils.nbsp,
    bufname
  )
  return item_str
end

M.buffers = function(opts)
  opts = config.normalize_opts(opts, 'buffers')
  if not opts then
    return
  end

  opts.__fn_reload = opts.__fn_reload
    or function(_)
      return function(cb)
        local filtered, _, max_bufnr = filter_buffers(opts, core.CTX().buflist)

        if next(filtered) then
          local buffers = populate_buffer_entries(opts, filtered)
          for _, bufinfo in pairs(buffers) do
            local ok, entry = pcall(gen_buffer_entry, opts, bufinfo, max_bufnr)
            vim.print(entry)
            assert(ok and entry)
            cb(entry)
          end
        end
        cb(nil)
      end
    end

  -- build the "reload" cmd and remove '-- {+}' from the initial cmd
  local reload, id = shell.reload_action_cmd(opts, '{+}')
  local contents = reload:gsub('%-%-%s+{%+}$', '')
  opts.__reload_cmd = reload

  -- get current tab/buffer/previous buffer
  -- save as a func ref for resume to reuse
  opts._fn_pre_fzf = function()
    shell.set_protected(id)
    core.CTX(true) -- include `nvim_list_bufs` in context
  end

  if opts.fzf_opts['--header-lines'] == nil then
    opts.fzf_opts['--header-lines'] = (not opts.ignore_current_buffer and opts.sort_lastused) and '1'
  end

  opts = core.set_header(opts, opts.headers or { 'actions', 'cwd' })
  opts = core.set_fzf_field_index(opts)

  core.fzf_exec(contents, opts)
end

return M
