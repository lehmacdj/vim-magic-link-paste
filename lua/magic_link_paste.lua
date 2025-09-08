local mod = {}

-- Function to check if cursor is in a markdown link URL
mod.is_cursor_in_markdown_link_url = function()
  -- Use vim.show_pos() to get all highlighter info at cursor position
  local pos_info = vim.inspect_pos(nil, nil, nil, {
    treesitter = true,
    syntax = false,
    extmarks = false,
    semantic_tokens = false
  })

  for _, item in ipairs(pos_info.treesitter or {}) do
    if item.capture == 'markup.link.url' then
      return true
    end
  end

  return false
end

return mod
