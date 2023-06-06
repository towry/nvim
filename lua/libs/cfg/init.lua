local defaults = require('libs.cfg.defaults')

return {
  --- Setup vim.cfg.
  ---@param user_cfg table?
  setup = function(user_cfg)
    user_cfg = user_cfg or {}
    vim.validate({
      user_cfg = {
        user_cfg,
        "table",
        "expect user configurations to be table"
      }
    })
    vim.cfg = setmetatable(user_cfg, {
      __index = function(_, key)
        return defaults[key]
      end
    })
  end
}
