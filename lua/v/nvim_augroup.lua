---@private
local _autocmd_keys = { "event", "buffer", "pattern", "desc", "command", "group", "once", "nested" }
--- Validate the keys passed to as.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
    local incorrect = vim.iter(command):map(function(key, _)
        if not vim.tbl_contains(_autocmd_keys, key) then return key end
    end)
    if #incorrect > 0 then
        vim.schedule(function()
            local msg = ("Incorrect keys: %s"):format(table.concat(incorrect, ", "))
            vim.notify(msg, vim.log.levels.ERROR, { title = ("Autocmd: %s"):format(name) })
        end)
    end
end

---@class AutocmdArgs
---@field id number autocmd ID
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string?
---@field event  (string | string[])? list of autocommand events
---@field pattern (string | string[])? list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
local function nvim_augroup(name, ...)
    local commands = { ... }
    assert(name ~= "User", "The name of an augroup CANNOT be User")
    assert(#commands > 0, string.format("You must specify at least one autocommand for %s", name))
    local id = vim.api.nvim_create_augroup(name, { clear = true })
    for _, autocmd in ipairs(commands) do
        validate_autocmd(name, autocmd)
        ---@diagnostic disable-next-line: undefined-field
        if autocmd.enabled ~= false then
            local is_callback = type(autocmd.command) == "function"
            vim.api.nvim_create_autocmd(autocmd.event, {
                group = name,
                pattern = autocmd.pattern,
                desc = autocmd.desc,
                callback = is_callback and autocmd.command or nil,
                ---@diagnostic disable-next-line: assign-type-mismatch
                command = not is_callback and autocmd.command or nil,
                once = autocmd.once,
                nested = autocmd.nested,
                buffer = autocmd.buffer,
            })
        end
    end
    return id
end

return nvim_augroup
