require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- This ensure format on save only changed line using conform
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    local lines = vim.fn.system("git diff --unified=0"):gmatch "[^\n\r]+"
    local ranges = {}
    for line in lines do
      if line:find "^@@" then
        local line_nums = line:match "%+.- "
        if line_nums:find "," then
          local _, _, first, second = line_nums:find "(%d+),(%d+)"
          table.insert(ranges, {
            start = { tonumber(first), 0 },
            ["end"] = { tonumber(first) + tonumber(second), 0 },
          })
        else
          local first = tonumber(line_nums:match "%d+")
          table.insert(ranges, {
            start = { first, 0 },
            ["end"] = { first + 1, 0 },
          })
        end
      end
    end
    local format = require("conform").format
    for _, range in pairs(ranges) do
      format {
        range = range,
        lsp_fallback = true,
        timeout_ms = 100,
      }
    end

    -- Ensure the file is saved after formatting
    vim.cmd('write')
  end,
})
