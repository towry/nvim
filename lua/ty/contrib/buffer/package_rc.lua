local M = {}

M.setup_smart_splits = require('ty.contrib.buffer.splits_rc').setup_smart_splits

M.option_window_picker = {
  autoselect_one = true,
  selection_chars = "ABCDEFGHIJKLMNOPQRSTUVW"
}

return M
