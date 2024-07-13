return setmetatable({}, {
    __index = function(_, key)
        if key == 'init' then
            error('invalid call')
        end
        ---@diagnostic disable-next-line: redundant-return-value
        return require('v.' .. key)
    end
})
