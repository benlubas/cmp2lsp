local config = {
  -- sort sources by name. Sources that show up first will be given priority
  -- group sources together to show their completion suggestions at the same time like:
  -- `{ { 'path', 'lsp' }, { 'buffer' } }`
  -- for the above, 'buffer' will only show if 'path' and 'lsp' produce no results
  sources = {},
}

return {
  config = config,
  update_config = function(user_config)
    user_config = user_config or {}
    config = vim.tbl_deep_extend("force", config, user_config)
  end,
}
