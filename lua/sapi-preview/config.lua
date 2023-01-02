local db = require("sapi-preview.db")

local M = {
  options = {},
  endpoints = {},
  packages = {},
  package = '',
}

local default = {
  package = '',
  base_url = '',
  keep_state = true,
  -- base_urls should not be set and pushed to github, use
  -- environment variable SAPI_PREVIEW_URLS instead
  base_urls = {}
}

M.set_options = function (opts)
  M.options = opts
end

M.set_endpoints = function (endpoints)
  M.endpoints = endpoints
end

M.set_packages = function(packages)
  M.packages = packages
end

M.set_package = function(package)
  M.package = package
end

M.setup = function(opts)
  opts = opts or {}

  if opts.base_urls ~= nil and next(opts.base_urls) ~= nil then
    print("Warning: base_urls should be set with env variable SAPI_PREVIEW_URLS, semicolon separated.")
  end

  local options = {}
  for k, v in pairs(default) do
    options[k] = v
  end

  local base_urls = os.getenv("SAPI_PREVIEW_URLS")
  if base_urls ~= nil then
    for str in string.gmatch(base_urls, "([^;]+)") do
      table.insert(options.base_urls, str)
    end
  else
    print("SAPI_PREVIEW_URLS is empty.")
  end

  for k, v in pairs(opts) do
    options[k] = v
  end

  if options.keep_state then
    for k, _ in pairs(default) do
      local v = db.get_default(k)
      if v ~= nil then
        options[k] = v
      end
    end
  end

  if options.base_url == "" then
    local bu = options.base_urls[1]
    if bu ~= nil then
      options.base_url = bu
    end
  end

  M.options = options
end


return M