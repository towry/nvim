-- Fast and feature-rich surround actions. For text that includes
-- surrounding characters like brackets or quotes, this allows you
-- to select the text inside, change or modify the surrounding characters,
-- and more.
return {
    "echasnovski/mini.surround",
    keys = function(_, keys)
        local maps = {
            add = "gsa",            -- Add surrounding in Normal and Visual modes
            delete = "gsd",         -- Delete surrounding
            find = "gsf",           -- Find surrounding (to the right)
            find_left = "gsF",      -- Find surrounding (to the left)
            highlight = "gsh",      -- Highlight surrounding
            replace = "gsr",        -- Replace surrounding
            update_n_lines = "gsn", -- Update `n_lines`
        }
        local mappings = {
            { maps.add,            desc = "Add Surrounding",                     mode = { "n", "v" } },
            { maps.delete,         desc = "Delete Surrounding" },
            { maps.find,           desc = "Find Right Surrounding" },
            { maps.find_left,      desc = "Find Left Surrounding" },
            { maps.highlight,      desc = "Highlight Surrounding" },
            { maps.replace,        desc = "Replace Surrounding" },
            { maps.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
        }
        mappings = vim.tbl_filter(function(m)
            return m[1] and #m[1] > 0
        end, mappings)
        return vim.list_extend(mappings, keys)
    end,
    opts = {
        mappings = {
            add = "gsa",            -- Add surrounding in Normal and Visual modes
            delete = "gsd",         -- Delete surrounding
            find = "gsf",           -- Find surrounding (to the right)
            find_left = "gsF",      -- Find surrounding (to the left)
            highlight = "gsh",      -- Highlight surrounding
            replace = "gsr",        -- Replace surrounding
            update_n_lines = "gsn", -- Update `n_lines`
        },
    },
}
