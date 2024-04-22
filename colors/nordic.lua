local c = require('nord.colors').palette
local utils = require('nord.utils')
local none = 'NONE'

do
  vim.cmd.highlight('clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd.syntax('reset')
  end

  local bg = vim.o.background
  if vim.o.background == 'dark' then
    require('nord').load()
    vim.g.colors_name = 'nordic'
    return
  else
    vim.cmd.source('$VIMRUNTIME/colors/default.vim')
    vim.o.background = bg
  end
  vim.g.colors_name = 'nordic'
end

-- -++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local bg = c.snow_storm.brighter

local function load(highlights)
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end
---- not working well
local function darken(hex, amount, bgcolor)
  return utils.blend(hex, bgcolor, amount)
end

local Defaults = {
  Normal = {
    bg = bg,
    fg = c.polar_night.bright,
  },
  CursorLine = { bg = c.snow_storm.origin, fg = none },
  StatusLine = { bg = c.frost.ice, fg = c.polar_night.brighter }, -- status line of current window
  StatusLineNC = { bg = c.snow_storm.origin, fg = c.polar_night.brightest }, -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
  TabLine = { bg = c.snow_storm.origin, fg = c.fg_gutter }, -- tab pages line, not active tab page label
  TabLineFill = { bg = c.snow_storm.origin, fg = c.polar_night.bright }, -- tab pages line, where there are no labels
  TabLineSel = { bg = c.frost.ice, fg = c.polar_night.brightest }, -- tab pages line, active tab page label
}

local Plugins = {
  MiniCursorword = {
    italic = true,
    bold = true,
    underline = false,
    bg = none,
    fg = none,
  },
  MiniCursorwordCurrent = {
    underline = false,
    bold = true,
    bg = none,
    fg = none,
  },
  MiniIndentscopeSymbol = {
    fg = c.snow_storm.origin,
  },
}

load(Defaults)
load(Plugins)
