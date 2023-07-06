local hooks = {}

return {
  ---Trigger select folder action.
  ---@param path string
  trigger_select_folder_action = function(path)
    local hook = hooks.select_folder_action
    if not hook then return end
    hook(path)
  end,
  ---@param cb function
  register_select_folder_action = function(cb)
    if type(cb) ~= 'function' then
      error('invalid parameter')
    end
    hooks.select_folder_action = cb
  end
}
