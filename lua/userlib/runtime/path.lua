local uv = vim.uv
local Table = require('userlib.runtime.table')
local is_windows = uv.os_uname().version:match('Windows')
local path_separator = is_windows and '\\' or '/'

local function remove_path_last_separator(path)
  if not path then return '' end
  if path:sub(#path) == path_separator then return path:sub(1, #path - 1) end
  return path
end

---@param path string
---@param segments_left? number
---@return string
local function shorten(path, segments_left)
  local ok, pathlib = pcall(require, 'plenary.path')
  if not ok then return vim.fn.pathshorten(path) end
  return pathlib:new(path):shorten(segments_left)
end

---@param path string
---@param cwd string
---@return string
local function make_relative(path, cwd)
  local ok, pathlib = pcall(require, 'plenary.path')
  if not ok then return path end
  return pathlib:new(path):make_relative(cwd)
end

local function escape_wildcards(path) return path:gsub('([%[%]%?%*])', '\\%1') end

---@param path string
---@param opts? {shorten?:boolean}
---@return string
local function home_to_tilde(path, opts)
  opts = opts or {}
  if not path then return '/tmp/wonderland' end
  -- local home = vim.loop.os_homedir()
  -- if path:sub(1, #home) == home then
  --   return '~' .. path:sub(#home + 1)
  -- end
  -- return path
  -- below not work for some case.
  local trimed = vim.fn.fnamemodify(path, ':~')
  if opts.shorten then return shorten(trimed, 2) end
  return trimed
end

local function sanitize(path)
  if is_windows then
    path = path:sub(1, 1):upper() .. path:sub(2)
    path = path:gsub('\\', '/')
  end
  return path
end

local function exists(filename)
  local stat = uv.fs_stat(filename)
  return stat and stat.type or false
end

local function is_dir(filename) return exists(filename) == 'directory' end

local function is_file(filename) return exists(filename) == 'file' end

local function is_home_dir(path)
  local homeDir = os.getenv('HOME') or os.getenv('USERPROFILE') or vim.uv.os_homedir()
  homeDir = homeDir:gsub('[\\/]+$', '') -- Remove trailing path separators
  path = path:gsub('[\\/]+$', '') -- Remove trailing path separators
  return path == homeDir
end

local function is_fs_root(path)
  if is_windows then
    return path:match('^%a:$')
  else
    return path == '/'
  end
end

local function is_absolute(filename)
  if is_windows then
    return filename:match('^%a:') or filename:match('^\\\\')
  else
    return filename:match('^/')
  end
end

local function dirname(path)
  local strip_dir_pat = '/([^/]+)$'
  local strip_sep_pat = '/$'
  if not path or #path == 0 then return end
  local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
  if #result == 0 then
    if is_windows then
      return path:sub(1, 2):upper()
    else
      return '/'
    end
  end
  return result
end

local function path_join(...)
  local args = ...
  if args and args[1] and type(args[1]) == 'table' then
    return table.concat(vim.tbl_flatten(args[1]), path_separator)
  end

  return table.concat(vim.tbl_flatten({ ... }), path_separator)
end

---@param path_string string
local function path_split(path_string)
  local pat = '[^' .. path_separator .. ']+'
  local result = {}
  for part in string.gmatch(path_string, pat) do
    table.insert(result, part)
  end
  return result
end

--- level up a path by level_number
---@param level_number number
---@return string
local function level_up_by(path_string, level_number)
  if type(path_string) ~= 'string' then return '/tmp/error/level_up_by' end
  if level_number <= 0 or level_number >= 20 then return path_string end
  local parts = path_split(path_string)
  local head_num = #parts - level_number - 1
  if head_num <= 0 then head_num = 1 end
  local results = Table.head(head_num, parts)

  --- path_split removed the first `/` in path_string, add it back.
  --- FIXME: buggy
  if is_windows then return path_join(results) end
  return path_join('', unpack(results))
end

-- Traverse the path calling cb along the way.
local function traverse_parents(path, cb)
  path = uv.fs_realpath(path)
  local dir = path
  -- Just in case our algo is buggy, don't infinite loop.
  for _ = 1, 100 do
    dir = dirname(dir)
    if not dir then return end
    -- If we can't ascend further, then stop looking.
    if cb(dir, path) then return dir, path end
    if is_fs_root(dir) then break end
  end
end

-- Iterate the path until we find the rootdir.
local function iterate_parents(path)
  local function it(_, v)
    if v and not is_fs_root(v) then
      v = dirname(v)
    else
      return
    end
    if v and uv.fs_realpath(v) then
      return v, path
    else
      return
    end
  end

  return it, path, path
end

local function search_ancestors(startpath, func)
  vim.validate({ func = { func, 'f' } })
  if func(startpath) then return startpath end
  local guard = 100
  for path in iterate_parents(startpath) do
    -- Prevent infinite recursion if our algorithm breaks
    guard = guard - 1
    if guard == 0 then return end

    if func(path) then return path end
  end
end

local function is_descendant(root, path)
  if not path then return false end

  local function cb(dir, _) return dir == root end

  local dir, _ = traverse_parents(path, cb)

  return dir == root
end

return {
  remove_path_last_separator = remove_path_last_separator,
  escape_wildcards = escape_wildcards,
  is_dir = is_dir,
  is_file = is_file,
  is_absolute = is_absolute,
  exists = exists,
  dirname = dirname,
  join = path_join,
  path_join = path_join,
  path_split = path_split,
  level_up_by = level_up_by,
  sanitize = sanitize,
  traverse_parents = traverse_parents,
  iterate_parents = iterate_parents,
  is_descendant = is_descendant,
  path_separator = path_separator,
  search_ancestors = search_ancestors,
  home_to_tilde = home_to_tilde,
  shorten = shorten,
  make_relative = make_relative,
  is_home_dir = is_home_dir,
  is_fs_root = is_fs_root,
}
