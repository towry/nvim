--- https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/lsp/filetypes.lua

local M = {}

M.config = {
  ['typescript'] = {
    formatter = 'prettier',
  },
  ['vue'] = {
    formatter = 'prettier',
  },
  ['lua'] = {
    -- cargo install stylua
    formatter = 'stylua',
    linter = 'luacheck',
  },
  ['go'] = {
    formatter = 'gofmt',
  },
  ['markdown'] = {
    formatter = {
      'prettier',
      'cbfmt',
    },
  },
  ['sh'] = {
    linter = 'shellcheck',
    formatter = 'shfmt',
  },
  ['nix'] = {
    linter = 'statix',
    formatter = 'nixfmt',
  },
}
-- these all use the same config
M.config['javascript'] = M.config['typescript']
M.config['typescriptreact'] = M.config['typescript']
M.config['javascriptreact'] = M.config['typescript']

M.filetypes = vim.tbl_keys(M.config)

local efm_customizations = {
  ['cbfmt'] = function()
    local cbfmt = require('efmls-configs.formatters.cbfmt')
    cbfmt.formatCommand =
      string.format('%s --config %s', cbfmt.formatCommand, string.format('%s/.config/cbfmt.toml', vim.env.HOME))
    return cbfmt
  end,
}

local function load_efm_modules(mods, mod_type)
  if not mods then return nil end

  -- normalize type to string[]
  mods = type(mods) == 'string' and { mods } or mods
  return vim.tbl_map(function(mod)
    if efm_customizations[mod] then return efm_customizations[mod]() end

    local ok, module = pcall(require, string.format('efmls-configs.%s.%s', mod_type, mod))
    if not ok then
      vim.notify(string.format('Module efmls-configs.%s.%s not found', mod_type, mod))
      return nil
    end
    return module
  end, mods)
end

local function load_linters(linters) return load_efm_modules(linters, 'linters') or {} end

local function load_formatters(formatters) return load_efm_modules(formatters, 'formatters') or {} end

function M.efmls_config(capabilities)
  local languages = {}
  for filetype, config in pairs(M.config) do
    if config.linter or config.formatter then
      languages[filetype] = vim.list_extend(load_formatters(config.formatter), load_linters(config.linter))
    end
  end

  return {
    filetypes = vim.tbl_keys(languages),
    settings = { languages = languages },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
    },
    capabilities = capabilities,
  }
end

function M.uses_efm(ft)
  ft = ft or vim.bo.ft
  return vim.tbl_get(M.config, ft, 'formatter') ~= nil or vim.tbl_get(M.config, ft, 'linter') ~= nil
end

function M.formats_with_efm(ft)
  ft = ft or vim.bo.ft
  return vim.tbl_get(M.config, ft, 'formatter') ~= nil
end

return M

