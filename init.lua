if vim.fn.has('win32') == 1 then

  vim.api.nvim_set_option("shell", "powershell")
  vim.api.nvim_set_option("shellcmdflag", "-command")
  vim.api.nvim_set_option("shellquote", "\"")
  vim.api.nvim_set_option("shellxquote", "")
end
vim.api.nvim_exec("set rnu", true)
-- vim.api.nvim_exec('language en_US', true)

-- vim.g.loaded_python3_provider = 1

-- local enable_providers = {
--       "python3_provider",
--     }
--     
--     for _, plugin in pairs(enable_providers) do
--       vim.g["loaded_" .. plugin] = nil
--       vim.cmd("runtime " .. plugin)
--     end

vim.g.maplocalleader = '<Space>'
vim.g["conjure.client.python.stdio.command"] = 'python -iq'

local function tab_win_closed(winnr)
  local api = require"nvim-tree.api"
  local tabnr = vim.api.nvim_win_get_tabpage(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local buf_info = vim.fn.getbufinfo(bufnr)[1]
  local tab_wins = vim.tbl_filter(function(w) return w~=winnr end, vim.api.nvim_tabpage_list_wins(tabnr))
  local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
  if buf_info.name:match(".*NvimTree_%d*$") then            -- close buffer was nvim tree
    -- Close all nvim tree on :q
    if not vim.tbl_isempty(tab_bufs) then                      -- and was not the last window (not closed automatically by code below)
      api.tree.close()
    end
  else                                                      -- else closed buffer was normal buffer
    if #tab_bufs == 1 then                                    -- if there is only 1 buffer left in the tab
      local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
      if last_buf_info.name:match(".*NvimTree_%d*$") then       -- and that buffer is nvim tree
        vim.schedule(function ()
          if #vim.api.nvim_list_wins() == 1 then                -- if its the last buffer in vim
            vim.cmd "quit"                                        -- then close all of vim
          else                                                  -- else there are more tabs open
            vim.api.nvim_win_close(tab_wins[1], true)             -- then close only the tab
          end
        end)
      end
    end
  end
end

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function ()
    local winnr = tonumber(vim.fn.expand("<amatch>"))
    vim.schedule_wrap(tab_win_closed(winnr))
  end,
  nested = true
})

