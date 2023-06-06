local header_static_str = [[
       _,    _   _    ,_
  .o888P     Y8o8Y     Y888o.
 d88888      88888      88888b
d888888b_  _d88888b_  _d888888b
8888888888888888888888888888888
8888888888888888888888888888888
YJGS8P"Y888P"Y888P"Y888P"Y8888P
 Y888   '8'   Y8P   '8'   888Y
  '8o          V          o8'
    `                     `
  ]]

return {
    "echasnovski/mini.starter",
    enabled = false,
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
        -- local logo = {}
        -- local insert = table.insert
        -- for line in header_static_str:gmatch('[^\r\n]+') do
        --     insert(logo, line)
        -- end
        local logo = header_static_str
        local pad = string.rep(" ", 22)
        local new_section = function(name, action, section)
            return { name = name, action = action, section = pad .. section }
        end

        local starter = require("mini.starter")
        --stylua: ignore
        local config = {
            evaluate_single = true,
            header = logo,
            items = {
                new_section("Find file", "Telescope find_files", "Telescope"),
                new_section("Recent files", "Telescope oldfiles", "Telescope"),
                new_section("Grep text", "Telescope live_grep", "Telescope"),
                new_section("init.lua", "e $MYVIMRC", "Config"),
                new_section("Lazy", "Lazy", "Config"),
                new_section("New file", "ene | startinsert", "Built-in"),
                new_section("Quit", "qa", "Built-in"),
                new_section("Session restore", [[lua require("persistence").load()]], "Session"),
            },
            content_hooks = {
                starter.gen_hook.adding_bullet(pad .. "░ ", false),
                starter.gen_hook.aligning("center", "center"),
            },
        }
        return config
    end,
    config = function(_, config)
        -- close Lazy and re-open when starter is ready
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniStarterOpened",
                callback = function()
                    require("lazy").show()
                end,
            })
        end

        local starter = require("mini.starter")
        starter.setup(config)

        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyVimStarted",
            callback = function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                local pad_footer = string.rep(" ", 8)
                starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
                pcall(starter.refresh)
            end,
        })
    end,
}
