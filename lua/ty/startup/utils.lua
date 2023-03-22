local insert = table.insert
local ImportConfig = 'ImportConfig'
local Feature = 'Feature'
local ImportOption = 'ImportOption'
local ImportInit = 'ImportInit'

local function load_modules_packages(specs, plugins_initd)
  local pack_initd = {}
  local pack_repos = {}
  local scoped_initd = nil
  -- specs is dict with { 'scope': list of plugins }
  for scope, plugins in pairs(specs) do
    scoped_initd = plugins_initd[scope] or {}
    if scoped_initd.init then insert(pack_initd, scoped_initd.init) end

    for _, repo in ipairs(plugins) do
      if repo.config == nil and type(repo[ImportConfig]) == 'string' then
        local local_config_key = repo[ImportConfig]
        repo.config = function(...)
          local is_ok, rc = pcall(require, 'ty.contrib.' .. scope .. '.package_rc')
          if not is_ok then
            print('package rc not found for ' .. scope)
            return
          end
          local setup_method = rc['setup_' .. local_config_key]
          if type(setup_method) == 'function' then
            setup_method(...)
          else
            error('invalid package ImportConfig for ' .. local_config_key)
          end
        end
        repo[ImportConfig] = nil
      end
      -- load opts.
      if repo.opts == nil and type(repo[ImportOption]) == 'string' then
        local local_opts_key = repo[ImportOption]
        repo.opts = function() return require('ty.contrib.' .. scope .. '.package_rc')['option_' .. local_opts_key] end
        repo[ImportOption] = nil
      end
      -- load init.
      if type(repo[ImportInit]) == 'string' and repo.init == nil and scoped_initd[repo[ImportInit]] then
        repo.init = scoped_initd[repo[ImportInit]]
        repo[ImportOption] = nil
      end
      -- insert
      insert(pack_repos, repo)
    end
  end

  return {
    repos = pack_repos,
    initd = pack_initd,
  }
end

return {
  load_modules_packages = load_modules_packages,
}
