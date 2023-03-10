local curl = require("endpoint-previewer.curl")
local utils = require("endpoint-previewer.utils")

local M = {}

function M.fetch_and_display(fetchUrl, opts)
  opts = opts or {}

  if opts.format == nil then
    opts.format = true
  end

  local buf_name = fetchUrl --:gsub("/", "_")
  local buf = opts.buf

  if not buf then
    buf = utils.new_or_existing_buffer(buf_name, 'botright vnew')
  end

  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, buf_name)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<cr>', {})
  if opts.diff then
    vim.cmd('diffthis')
  end

  if utils.ends_with(fetchUrl, '.xml') then
    vim.api.nvim_buf_set_option(buf, 'filetype', 'html')
  end

  if utils.ends_with(fetchUrl, '.json') then
    vim.api.nvim_buf_set_option(buf, 'filetype', 'json')
  end

  local function on_exit(result)
    if vim.fn.bufexists(buf) == 0 then
      vim.notify("Buffer closed for " .. fetchUrl .. " - unable to update.")
      return
    end
    local lines = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, 0, lines, false, {})
    vim.api.nvim_buf_call(buf, function()
      vim.api.nvim_put(result.output, "", false, false)
    end)
--    if result.status_code == 200 then
--      print("Fetched " .. fetchUrl)
--    else
--      print("Got status code " .. result.status_code .. " for " .. fetchUrl)
--    end
    if opts.debug then
      require("endpoint-previewer.dap").stop()
    end
  end

--  print("Fetching " .. fetchUrl .. "... ")
  curl.fetch_async(fetchUrl, on_exit)
end

return M
