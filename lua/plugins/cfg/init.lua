local defaults = require('userlib.cfg.defaults')

return {
  --- Setup vim.cfg.
  ---@param user_cfg table?
  setup = function(user_cfg)
    user_cfg = user_cfg or {}
    vim.validate({
      user_cfg = {
        user_cfg,
        'table',
        'expect user configurations to be table',
      },
    })
    user_cfg = vim.tbl_extend('force', user_cfg, vim.g.user_cfg or {})
    vim.cfg = setmetatable(user_cfg, {
      __index = function(_, key)
        return defaults[key]
      end,
    })
  end,
}
