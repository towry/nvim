return {
  'echasnovski/mini.clue',
  event = { 'CursorHold', 'CursorHoldI' },
  opts = function()
    return {
      window = {
        delay = 200,
        config = {
          width = 'auto',
        },
      },
      triggers = {},
      clues = {
        vim.g.miniclues,
      },
    }
  end,
  init = function() end,
}
