local plug = require('userlib.runtime.pack').plug

return plug({
  event = 'InsertEnter',
  cmd = {
    'WakaTimeApiKey',
    'WakaTimeDebugEnable',
    'WakaTimeDebugDisable',
    'WakaTimeToday',
  },
  'wakatime/vim-wakatime',
})
