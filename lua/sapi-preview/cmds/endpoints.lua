local actions = require("sapi-preview.actions")
local conf = require("sapi-preview.config")

local M = {}

M.endpoints = function(opts)
  opts = opts or {}

  if conf.endpoints.examples == nil then
    print("No examples, updating endpoints")
    require("sapi-preview.cmds.update_endpoints").update_endpoints(opts)
  end

  require("telescope.pickers").new(opts, {
    prompt_title = "Endpoints (" .. conf.options.base_url .. ")",
    finder = require("telescope.finders").new_table {
      results = conf.endpoints.examples,
    },
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(buf, map)
      require("telescope.actions").select_default:replace(actions.telescope_select_endpoint)
      map('n', 'c', actions.telescope_compare_endpoint)

      return true
    end
  }):find()
end


return M
