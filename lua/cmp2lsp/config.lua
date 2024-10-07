local M = {}

M.config = {
  -- sort sources by name. Sources that show up first will be given priority
  -- group sources together to show their completion suggestions at the same time like:
  -- `{ { 'path', 'lsp' }, { 'buffer' } }`
  -- for the above, 'buffer' will only show if 'path' and 'lsp' produce no results
  sources = {},
}

M.update_config = function(user_config)
  user_config = user_config or {}
  M.config = vim.tbl_deep_extend("force", M.config, user_config)
end

return M
