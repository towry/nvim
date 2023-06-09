-- prevent the cursor from moving when using shift and filter actions.
return { 'gbprod/stay-in-place.nvim', config = true, event = 'BufReadPost' }
