return {
  -- git
  {
    -- TODO: check the file type before running this command.
    -- maybe use a util function to check normal file.
    ':Git diff %',
    description = 'Git diff current buffer',
  },
  -- git signs
  {
    ":lua require('gitsigns').stage_hunk()",
    description = 'Gitsigns stage hunk',
  },
  {
    ":lua require('gitsigns').undo_stage_hunk()",
    description = 'Gitsigns undo stage hunk',
  },
  {
    ":lua require('gitsigns').reset_hunk()",
    description = 'Gitsigns reset hunk',
  },
  {
    ":lua require('gitsigns').stage_buffer()",
    description = 'Gitsigns stage buffer',
  },
  {
    ":lua require('gitsigns').reset_buffer()",
    description = 'Gitsigns reset buffer',
  },
  {
    ":lua require('gitsigns').preview_hunk()",
    description = 'Gitsigns preview hunk',
  },
  {
    ":lua require('gitsigns').diffthis()",
    description = 'Gitsigns diff this',
  },
  {
    ":lua require('gitsigns').toggle_deleted()",
    description = 'Gitsigns toggle deleted',
  },
  {
    ':Gitsigns toggle_numhl',
    description = 'Gitsigns toggle num highlight/numhl',
  },
  {
    ':Gitsigns toggle_linehl',
    description = 'Gitsigns toggle line highlight/linehl',
  },
}
