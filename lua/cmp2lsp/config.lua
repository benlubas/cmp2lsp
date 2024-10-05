local config = {
  -- when true, will complete from the first source that it finds. Sources are checked in order that
  -- they're registered
  break_after_match = false,
}

return {
  config = config,
  update_config = function(user_config)
    user_config = user_config or {}
    config = vim.tbl_deep_extend("force", config, user_config)
  end,
}
