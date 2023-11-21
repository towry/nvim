-- local heirline = require('heirline')
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local format_utils = require('userlib.lsp.servers.null_ls.fmt')
local auto_format_disabled = require('userlib.lsp.servers.null_ls.autoformat').disabled

local Spacer = { provider = " " }
local function rpad(child)
  child = child or {}
  return {
    condition = child.condition,
    child,
    Spacer,
  }
end
local function lpad(child)
  child = child or {}
  return {
    condition = child.condition,
    Spacer,
    child,
  }
end

local stl_static = {
  mode_color_map = {
    n = "function",
    i = "green",
    v = "statement",
    V = "statement",
    ["\22"] = "statement",
    c = "yellow",
    s = "statement",
    S = "statement",
    ["\19"] = "statement",
    R = "red",
    r = "red",
    ["!"] = "constant",
    t = "constant",
  },
  mode_color = function(self)
    local mode = vim.fn.mode(1):sub(1, 1) -- get only the first mode character
    return self.mode_color_map[mode]
  end,
}

local ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()

    -- execute this only once, this is required if you want the ViMode
    -- component to be updated on operator pending mode
    if not self.once then
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*o",
        command = "redrawstatus",
      })
      self.once = true
    end
  end,
  -- Now we define some dictionaries to map the output of mode() to the
  -- corresponding string and color. We can put these into `static` to compute
  -- them at initialisation time.
  static = {
    mode_names = {
      n = "NORMAL",
      no = "NORMAL-",
      nov = "NORMAL-",
      noV = "NORMAL-",
      ["no\22"] = "NORMAL-",
      niI = "NORMAL-",
      niR = "NORMAL-",
      niV = "NORMAL-",
      nt = "NORMAL-",
      v = "VISUAL",
      vs = "VISUAL-",
      V = "V-LINE",
      Vs = "V-LINE-",
      ["\22"] = "V-BLOCK",
      ["\22s"] = "V-BLOCK-",
      s = "SELECT",
      S = "S-LINE",
      ["\19"] = "S-BLOCK",
      i = "INSERT",
      ic = "INSERT-",
      ix = "INSERT-",
      R = "REPLACE",
      Rc = "REPLACE-",
      Rx = "REPLACE-",
      Rv = "REPLACE-",
      Rvc = "REPLACE-",
      Rvx = "REPLACE-",
      c = "COMMAND",
      cv = "COMMAND-",
      r = "PROMPT",
      rm = "MORE",
      ["r?"] = "CONFIRM",
      ["!"] = "SHELL",
      t = "TERMINAL",
    },
  },
  provider = function(self) return " " .. self.mode_names[self.mode] .. " " end,
  hl = function(self) return { fg = "black", bg = self:mode_color(), bold = true } end,
  update = {
    "ModeChanged",
  },
}

local FileIcon = {
  init = function(self)
    self.icon, self.icon_color =
        require("nvim-web-devicons").get_icon_color_by_filetype(vim.bo.filetype, { default = true })
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return { fg = self.icon_color } end,
}

local FileType = {
  condition = function() return vim.bo.filetype ~= "" end,
  FileIcon,
  {
    provider = function()
      local ft = vim.bo.filetype
      if #ft > 4 then
        -- pick first two and last one
        ft = ft:sub(1, 2) .. '~' .. ft:sub(#ft, #ft)
        return ft
      end
      return ft
    end,
  },
}

local FileName = {
  provider = function(self)
    local filename = vim.b.relative_path or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
    if filename == "" then
      return "[No Name]"
    end
    -- now, if the filename would occupy more than 90% of the available
    -- space, we trim the file path to its initials
    if not conditions.width_percent_below(#filename, 0.90) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
}

local BufferCwd = {
  provider = function(self)
    local cwd = vim.fn.fnamemodify(vim.b.project_nvim_cwd or vim.uv.cwd(), ':t')
    if not cwd or cwd == '' then return '' end

    return ' ' .. cwd
  end
}

local FileFlags = {
  {
    condition = function() return vim.bo.modified end,
    provider = " [+]",
  },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = " ",
  },
}

local FullFileName = {
  hl = function()
    local fg
    if vim.bo.modified then
      fg = "yellow"
    else
      fg = conditions.is_active() and "tablinesel_fg" or "tabline_fg"
    end
    return {
      fg = fg,
      bg = conditions.is_active() and "tablinesel_bg" or "winbar_bg",
    }
  end,
  FileName,
  FileFlags,
  { provider = "%=" },
}

local DirAndFileName = {
  hl = function()
    local fg
    if vim.bo.modified then
      fg = "yellow"
    else
      fg = conditions.is_active() and "tablinesel_fg" or "tabline_fg"
    end
    return {
      fg = fg,
      bg = conditions.is_active() and "tablinesel_bg" or "winbar_bg",
    }
  end,
  lpad(BufferCwd),
  lpad(FileName),
  { provider = "#%1.3n.%{tabpagewinnr(tabpagenr())}" },
  FileFlags,
  { provider = "%=" },
}


local function OverseerTasksForStatus(status)
  return {
    condition = function(self) return self.tasks[status] end,
    provider = function(self) return string.format("%s%d", self.symbols[status], #self.tasks[status]) end,
    hl = function(self)
      return {
        fg = utils.get_highlight(string.format("Overseer%s", status)).fg,
      }
    end,
  }
end
local Overseer = {
  condition = function() return package.loaded.overseer end,
  init = function(self)
    local tasks = require("overseer.task_list").list_tasks({ unique = true })
    local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
    self.tasks = tasks_by_status
  end,
  static = {
    symbols = {
      ["CANCELED"] = " ",
      ["FAILURE"] = "󰅚 ",
      ["SUCCESS"] = "󰄴 ",
      ["RUNNING"] = "󰑮 ",
    },
  },

  rpad(OverseerTasksForStatus("CANCELED")),
  rpad(OverseerTasksForStatus("RUNNING")),
  rpad(OverseerTasksForStatus("SUCCESS")),
  rpad(OverseerTasksForStatus("FAILURE")),
}

local function setup_colors()
  return {
    fg = utils.get_highlight("StatusLine").fg or "none",
    bg = utils.get_highlight("StatusLine").bg or "none",
    winbar_fg = utils.get_highlight("WinBar").fg or "none",
    winbar_bg = utils.get_highlight("WinBar").bg or "none",
    tablinesel_fg = utils.get_highlight("TabLineSel").fg or "none",
    tablinesel_bg = utils.get_highlight("TabLineSel").bg or "none",
    tabline_fg = utils.get_highlight("TabLine").fg or "none",
    red = utils.get_highlight("DiagnosticError").fg or "none",
    yellow = utils.get_highlight("DiagnosticWarn").fg or "none",
    green = utils.get_highlight("DiagnosticOk").fg or "none",
    gray = utils.get_highlight("NonText").fg or "none",
    ["function"] = utils.get_highlight("Function").fg or "none",
    constant = utils.get_highlight("Constant").fg or "none",
    statement = utils.get_highlight("Statement").fg or "none",
    visual = utils.get_highlight("Visual").bg or "none",
    diag_warn = utils.get_highlight("DiagnosticWarn").fg or "none",
    diag_error = utils.get_highlight("DiagnosticError").fg or "none",
  }
end

local ArduinoStatus = {
  condition = function() return vim.bo.filetype == "arduino" end,
  provider = function()
    local port = vim.fn["arduino#GetPort"]()
    local line = string.format("[%s]", vim.g.arduino_board)
    if vim.g.arduino_programmer ~= "" then
      line = line .. string.format(" [%s]", vim.g.arduino_programmer)
    end
    if port ~= 0 then
      line = line .. string.format(" (%s:%s)", port, vim.g.arduino_serial_baud)
    end
    return line
  end,
}

-- HACK I don't know why, but the stock implementation of lsp_attached is causing error output
-- (UNKNOWN PLUGIN): Error executing lua: attempt to call a nil value
-- It gets written to raw stderr, which then messes up all of vim's rendering. It's something to do
-- with the require("vim.lsp") call deep in the vim metatable __index function. I don't know the
-- root cause, but I'm done debugging this for today.
conditions.lsp_attached = function()
  local lsp = rawget(vim, "lsp")
  return lsp and next(lsp.get_active_clients({ bufnr = 0 })) ~= nil
end

local LSPActive = {
  update = { "LspAttach", "LspDetach", "VimResized", "FileType", "BufEnter", "BufWritePost" },

  flexible = 1,
  {
    provider = function()
      local names = {}
      local lsp = rawget(vim, "lsp")
      if lsp then
        for _, server in pairs(lsp.get_active_clients({ bufnr = 0 })) do
          table.insert(names, server.name)
        end
      end
      local lint = package.loaded.lint
      if lint and vim.bo.buftype == "" then
        table.insert(names, "⫽")
        for _, linter in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          table.insert(names, linter)
        end
      end
      local conform = package.loaded.conform
      if conform and vim.bo.buftype == "" then
        local formatters = conform.list_formatters(0)
        if not conform.will_fallback_lsp() then
          table.insert(names, "⫽")
          for _, formatter in ipairs(formatters) do
            table.insert(names, formatter.name)
          end
        end
      end
      if vim.tbl_isempty(names) then
        return ""
      else
        return " [" .. table.concat(names, " ") .. "]"
      end
    end,
  },
  {
    condition = conditions.lsp_attached,
    provider = " [LSP]",
  },
  {
    condition = conditions.lsp_attached,
    provider = " ",
  },
}

local Ruler = {
  provider = " %P %l:%c ",
  hl = function(self) return { fg = "black", bg = self:mode_color(), bold = true } end,
}

local Branch = {
  condition = function()
    return vim.fn.exists("*FugitiveHead") == 1
  end,
  init = function(self)
    if vim.fn.exists("*FugitiveHead") then
      self.head = vim.fn["FugitiveHead"]()
    else
      self.head = ''
    end
  end,
  provider = function(self)
    return self.head ~= '' and ' ' .. self.head or ''
  end,
  update = {
    'User',
    pattern = 'FugitiveChanged',
  }
}

local Harpoon = {
  condition = function()
    local loaded = package.loaded.harpoon
    if not loaded then return false end
    return true
  end,
  init = function(self)
    self.harpoon_idx = require('harpoon.mark').status()
  end,
  provider = function(self)
    if not self.harpoon_idx or self.harpoon_idx == '' then return '' end
    return ' ' .. self.harpoon_idx
  end,
  hl = function()
    return {
      fg = "red",
    }
  end,
}

local ProfileRecording = {
  condition = function()
    local profile = package.loaded.profile
    return profile and profile.is_recording()
  end,
  provider = function() return "󰑊 " end,
  hl = function() return { fg = "red" } end,
  update = {
    "User",
    pattern = { "ProfileStart", "ProfileStop" },
  },
}

local DiagnosticsDisabled = {
  condition = function()
    return vim.diagnostic.is_disabled()
  end,
  provider = function() return " " end,
}

local WorkspaceRoot = {
  condition = function()
    return vim.cfg.runtime__starts_cwd_short ~= nil
  end,
  provider = function()
    return ' ' .. vim.cfg.runtime__starts_cwd_short
  end,
}

local Tabs = {
  condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
  utils.make_tablist {                                                  -- component for each tab
    provider = function(self)
      return (self and self.tabnr) and "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" or ""
    end,
    hl = function(self)
      if self.is_active then
        return { fg = "Green" }
      else
        return { fg = "Gray" }
      end
    end,
  },
  update = { 'VimEnter', 'TabNew', 'TabLeave' },
}

local LspFormatter = {
  init = function(self)
    local ftr_name, impl_ftr_name = format_utils.current_formatter_name(0)
    self.formatter_icon = '󰎟 '
    self.formatter_disable_icon = '󰙧 '
    self.formatter_name = impl_ftr_name or ftr_name or ''
    self.disabled = auto_format_disabled(0)
  end,
  provider = function(self)
    if self.formatter_name == '' then return '' end
    if self.disabled then
      return self.formatter_disable_icon
    end
    return string.format('%s%s', self.formatter_icon, self.formatter_name)
  end,
  update = { 'LspAttach', 'LspDetach', 'BufWinEnter' },
}

local Copilot = {
  condition = function()
    return vim.g.loaded_copilot == 1
  end,
  init = function(self)
    self.enable = self.get_status() == 1
  end,
  static = {
    running = false,
    count = -1,
    -- if this comes to 0, means no running finally.
    timer = nil,
    spin = '',
    get_status = function()
      if vim.g.loaded_copilot == 1 and vim.g.copilot_enabled ~= 0 then
        return 1
      else
        return 0
      end
    end,
    is_running = function()
      return vim.g.copilot_status == 'pending'
    end,
  },
  provider = function(self)
    if not self.enable then return '󱚧' end
    if not self.is_running() then return '󰚩' end
    return '󰆄'
  end,
  hl = function(self)
    local fg = vim.g.copilot_auto_mode == true and 'orange' or ''
    if self.is_running() then
      fg = "green"
    end
    return {
      fg = fg,
    }
  end,
  update = {
    'User',
    pattern = 'CopilotStatus',
    callback = vim.schedule_wrap(function()
      vim.cmd.redrawstatus()
    end)
  }
}

return {
  ViMode = ViMode,
  Ruler = Ruler,
  Spacer = Spacer,
  rpad = rpad,
  lpad = lpad,
  FileIcon = FileIcon,
  FileType = FileType,
  FullFileName = FullFileName,
  Overseer = Overseer,
  setup_colors = setup_colors,
  -- SessionName = SessionName,
  ArduinoStatus = ArduinoStatus,
  LSPActive = LSPActive,
  stl_static = stl_static,
  -- ConjoinStatus = ConjoinStatus,
  ProfileRecording = ProfileRecording,
  Branch = Branch,
  Harpoon = Harpoon,
  DirAndFileName = DirAndFileName,
  DiagnosticsDisabled = DiagnosticsDisabled,
  WorkspaceRoot = WorkspaceRoot,
  LspFormatter = LspFormatter,
  Tabs = Tabs,
  Copilot = Copilot,
}
