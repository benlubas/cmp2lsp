--- This file was originally authored by @max397574 for
--- care.nvim at: https://github.com/max397574/care-cmp/blob/main/lua/cmp/init.lua
---
--- It was modified slightly for this plugin's purposes

local sources = require("cmp2lsp.sources")

local cmp = {}

-- this file will be required in the place of nvim_cmp when you try to register a source.

function cmp.register_source(name, cmp_source)
  cmp_source.name = name
  cmp_source.display_name = name .. " (cmp)"
  if not cmp_source.is_available then
    cmp_source.is_available = function()
      return true
    end
  end
  local old_complete = cmp_source.complete
  cmp_source.complete = function(completion_context, callback)
    local cursor = { completion_context.context.cursor.row, completion_context.context.cursor.col }
    local cursor_line = completion_context.context.line
    local cmp_context = {
      option = { reason = completion_context.completion_context.triggerKind == 1 and "manual" or "auto" },
      filetype = vim.api.nvim_get_option_value("filetype", {
        buf = 0,
      }),
      time = vim.uv.now(),
      bufnr = completion_context.context.bufnr,
      cursor_line = completion_context.context.line,
      cursor = {
        row = cursor[1],
        col = cursor[2] - 1,
        line = cursor[1] - 1,
        character = cursor[2] - 1,
      },
      prev_context = completion_context.context.prev_context,
      get_reason = function(self)
        return self.option.reason
      end,
      cursor_before_line = completion_context.context.line_before_cursor,
      line_before_cursor = completion_context.context.line_before_cursor,
      cursor_after_line = string.sub(cursor_line, cursor[2] - 1),
    }
    local TODO = 3
    old_complete(cmp_source, {
      context = cmp_context,
      offset = TODO,
      completion_context = completion_context.completion_context,
      option = {},
      ---@diagnostic disable-next-line: redundant-parameter
    }, function(response)
      if not response then
        callback({})
        return
      end
      if response.isIncomplete ~= nil then
        callback(response.items or {}, response.isIncomplete == true)
        return
      end
      callback(response.items or response)
    end)
  end
  local old_get_keyword_pattern = cmp_source.get_keyword_pattern
  if old_get_keyword_pattern then
    cmp_source.get_keyword_pattern = function(self, _)
      return old_get_keyword_pattern(self, { option = {} })
    end
  end
  -- local old_execute = cmp_source.execute
  -- if old_execute then
  --   cmp_source.execute = function(self, entry, _)
  --     old_execute(self, entry.completion_item, function() end)
  --   end
  -- end

  table.insert(sources, vim.deepcopy(cmp_source))
end

cmp.lsp = {}
cmp.lsp.CompletionItemKind = {
  Text = 1,
  Method = 2,
  Function = 3,
  Constructor = 4,
  Field = 5,
  Variable = 6,
  Class = 7,
  Interface = 8,
  Module = 9,
  Property = 10,
  Unit = 11,
  Value = 12,
  Enum = 13,
  Keyword = 14,
  Snippet = 15,
  Color = 16,
  File = 17,
  Reference = 18,
  Folder = 19,
  EnumMember = 20,
  Constant = 21,
  Struct = 22,
  Event = 23,
  Operator = 24,
  TypeParameter = 25,
}

cmp.lsp.MarkupKind = { PlainText = "plaintext", Markdown = "markdown" }

cmp.ContextReason = {
  Auto = "auto",
  Manual = "manual",
  TriggerOnly = "triggerOnly",
  None = "none",
}


--     create_source = function()
--         -- these numbers come from: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind
--         module.private.completion_item_mapping = {
--             Directive = 14,
--             Tag = 14,
--             Language = 10,
--             TODO = 23,
--             Property = 10,
--             Format = 10,
--             Embed = 10,
--             Reference = 18,
--             File = 17,
--         }
--
--         function module.public.completion_handler(request, callback, _)
--             local abstracted_context = module.public.create_abstracted_context(request)
--
--             local completion_cache = module.public.invoke_completion_engine(abstracted_context)
--
--             if completion_cache.options.pre then
--                 completion_cache.options.pre(abstracted_context)
--             end
--
--             local completions = vim.deepcopy(completion_cache.items)
--
--             for index, element in ipairs(completions) do
--                 local insert_text = nil
--                 local label = element
--                 if type(element) == "table" then
--                     insert_text = element[1]
--                     label = element.label
--                 end
--                 completions[index] = {
--                     label = label,
--                     insertText = insert_text,
--                     kind = module.private.completion_item_mapping[completion_cache.options.type],
--                 }
--             end
--
--             callback(nil, completions)
--         end
--     end,
--
--     ---Provide categories as a completion source,
--     category_completion = function()
--         local norg_query = utils.ts_parse_query(
--             "norg",
--             [[
--                 (document
--                   (ranged_verbatim_tag
--                     ((tag_name) @tag_name (#eq? @tag_name "document.meta"))
--                     (ranged_verbatim_tag_content) @tag_content
--                   )
--                 )
--             ]]
--         )
--
--         local norg_parser, iter_src = ts.get_ts_parser(0)
--         if not norg_parser then
--             return {}
--         end
--         local norg_tree = norg_parser:parse()[1]
--         if not norg_tree then
--             return {}
--         end
--
--         local meta_node
--         for id, node in norg_query:iter_captures(norg_tree:root(), iter_src) do
--             if norg_query.captures[id] == "tag_content" then
--                 meta_node = node
--             end
--         end
--
--         if not meta_node then
--             return {}
--         end
--
--         local meta_source = ts.get_node_text(meta_node, iter_src)
--         local norg_meta_parser = vim.treesitter.get_string_parser(meta_source, "norg_meta")
--         local norg_meta_tree = norg_meta_parser:parse()[1]
--         if not norg_meta_tree then
--             return {}
--         end
--
--         local meta_query = utils.ts_parse_query(
--             "norg_meta",
--             [[
--                 (metadata
--                   (pair
--                     ((key) @key (#eq? @key "categories"))
--                     (value) @value
--                   ) @pair
--                 )
--             ]]
--         )
--
--         for id, node in meta_query:iter_captures(norg_meta_tree:root(), meta_source) do
--             if meta_query.captures[id] == "pair" then
--                 local range = ts.get_node_range(node)
--                 local meta_range = ts.get_node_range(meta_node)
--                 range.row_start = range.row_start + meta_range.row_start
--                 range.row_end = range.row_end + meta_range.row_start
--
--                 local cursor = vim.api.nvim_win_get_cursor(0)
--                 if cursor[1] - 1 >= range.row_start and cursor[1] - 1 <= range.row_end then
--                     return module.private.make_category_suggestions()
--                 end
--             end
--         end
--     end,
--
--     -- {
--     --   before_char = "@",
--     --   buffer = 12,
--     --   char = 4,
--     --   column = 5,
--     --   full_line = "   @",
--     --   line = "   @",
--     --   line_number = 32,
--     --   previous_context = {
--     --     column = 4,
--     --     line = "   ",
--     --     start_offset = 5
--     --   },
--     --   start_offset = 5
--     -- }
--     -- textDocument/completion
--     -- {
--     --   context = {
--     --     triggerCharacter = "@",
--     --     triggerKind = 2
--     --   },
--     --   position = {
--     --     character = 4,
--     --     line = 32
--     --   },
--     --   textDocument = {
--     --     uri = "file:///home/benlubas/notes/test1.norg"
--     --   }
--     -- }
--
--     create_abstracted_context = function(request)
--         local line_num = request.position.line
--         local col_num = request.position.character
--         local buf = vim.uri_to_bufnr(request.textDocument.uri)
--         local full_line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]
--
--         local before_char = (request.context and request.context.triggerCharacter) or full_line:sub(col_num, col_num)
--
--         return {
--             start_offset = col_num + 1,
--             char = col_num,
--             before_char = before_char,
--             line_number = request.position.line,
--             column = col_num + 1,
--             buffer = buf,
--             line = full_line:sub(1, col_num),
--             -- this is never used anywhere, so it's probably safe to ignore
--             -- previous_context = {
--             --     line = request.context.prev_context.cursor_before_line,
--             --     column = request.context.prev_context.cursor.col,
--             --     start_offset = request.offset,
--             -- },
--             full_line = full_line,
--         }
--     end,
--
--     invoke_completion_engine = function(context)
--         error("`invoke_completion_engine` must be set from outside.")
--         assert(context)
--         return {}
--     end,
-- }


return cmp
