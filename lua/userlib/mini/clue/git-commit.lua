local M = {}

---@param callback function
M.open = function(callback)
  local _ = function(prefix)
    return function()
      callback(prefix)
    end
  end

  require('userlib.mini.clue').shortly_open(function(set, unset)
    set('n', 'j', _('wip: <🤩>'), { desc = 'wip: <🤩>', noremap = true })
    set('n', 'f', _('fixup: <🐞>'), { desc = 'fixup: <🐞>' })
    set('n', 's', _('format: <💅>'), { desc = 'format: <💅>' })
    set('n', 't', _('test: <🐛>'), { desc = 'test: <🐛>' })
    set('n', 'r', _('refactor: <🐭>'), { desc = 'refactor: <🐭>' })
    set('n', 'd', _('doc: <📚>'), { desc = 'doc: <📚>' })
    set('n', 'p', _('perf: <🚀>'), { desc = 'perf: <🚀>' })
    set('n', 'c', _('chore: <🔨>'), { desc = 'chore: <🔨>' })
    set('n', 'b', _('build: <🏗️>'), { desc = 'build: <🏗️>' })
    set('n', 'i', _('ci: <👷>'), { desc = 'ci: <👷>' })
    set('n', 'a', _('deps: <📦>'), { desc = 'deps: <📦>' })
    set('n', 'e', _('typo: <🐛>'), { desc = 'typo: <🐛>' })
    set('n', 'l', _('cleanup: <🗑️>'), { desc = 'cleanup: <🗑️>' })
    set('n', 'x', _('revert: <🔙>'), { desc = 'revert: <🔙>' })
    set('n', 'u', _('feat: <🐸>'), { desc = 'feat: <🐸>' })
  end)
end

return M
