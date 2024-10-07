
local M = {}

-- track all the sources
M.sources = {}

---Sort sources into configuration order
M.sort_sources = function(config)
  local sorted = {}

  local source_by_name = function(name)
    for _, source in ipairs(M.sources) do
      if source.name == name then
        return source
      end
    end
  end

  for _, group in ipairs(config) do
    for _, name in ipairs(group) do
      local source = source_by_name(name)
      if not source_by_name(source) then
        vim.notify(("[cmp2lsp] invalid source name: `%s`"):format(name))
        return
      end

      table.insert(sorted, source)
    end
    table.insert(sorted, "group separator") -- yeah this is horribly hacky. it's a small plugin okay.
  end

  M.sources = sorted
end

return M
