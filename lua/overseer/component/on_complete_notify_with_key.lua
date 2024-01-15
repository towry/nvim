local on_complete_notify = require('overseer.component.on_complete_notify')

--- fidget allow vim.notify with key
return vim.tbl_deep_extend('force', on_complete_notify, {
  params = {
    key = {
      desc = 'Notify key if vim.notify agent allow',
      type = 'string',
      default = nil,
    },
    annote = {
      desc = 'Fidget prop',
      type = 'string',
      default = nil,
    },
  },
  constructor = function(params)
    local ret = on_complete_notify.constructor(params)
    local Notifier = {}
    function Notifier:notify(message, level)
      ---@diagnostic disable-next-line: redundant-parameter
      vim.notify(message, level, {
        key = params.key,
        annote = params.annote,
        ttl = 5,
      })
    end
    ret.notifier = Notifier
    return ret
  end,
})
