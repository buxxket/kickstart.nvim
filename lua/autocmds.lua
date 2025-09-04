-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
--   pattern = { '*.md', '*.markdown' },
--   command = 'silent! wall',
--   nested = true,
-- })

local debounce_timer = nil

vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
  pattern = { '*.md', '*.markdown' },
  callback = function()
    if debounce_timer then
      debounce_timer:stop()
      debounce_timer:close()
    end
    debounce_timer = vim.loop.new_timer()
    debounce_timer:start(
      500,
      0,
      vim.schedule_wrap(function()
        vim.cmd 'silent! wall'
      end)
    )
  end,
  nested = true,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.md',
  callback = function()
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line == '<!--md2githubhtml-->' then
        local filepath = vim.fn.expand '%:p'
        vim.fn.jobstart({ os.getenv 'HOME' .. '/bin/md2githubhtml', filepath }, {
          -- on_exit = function(_, code, _)
          --   vim.schedule(function()
          --     if code == 0 then
          --       vim.notify('md2githubhtml: Conversion successful for ' .. filepath, vim.log.levels.INFO)
          --     else
          --       vim.notify('md2githubhtml: Conversion failed for ' .. filepath, vim.log.levels.ERROR)
          --     end
          --   end)
          -- end,
          stdout_buffered = true,
          stderr_buffered = true,
          detach = true,
        })
        break
      end
    end
  end,
})
