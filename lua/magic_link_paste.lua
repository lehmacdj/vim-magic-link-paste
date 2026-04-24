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

-- Intercept bracketed paste in charwise visual mode so that terminal-level
-- paste shortcuts (e.g. Cmd-V in kitty) route through the plugin's paste
-- logic instead of replacing the selection with plain text.
mod.setup_paste_override = function(filetypes)
  local ft_set = {}
  for _, ft in ipairs(filetypes) do ft_set[ft] = true end
  local original = vim.paste
  vim.paste = function(lines, phase)
    if phase ~= -1
       or #lines == 0
       or vim.api.nvim_get_mode().mode ~= 'v'
       or not ft_set[vim.bo.filetype] then
      return original(lines, phase)
    end
    vim.fn.setreg('"', table.concat(lines, '\n'))
    vim.schedule(function()
      vim.fn['magic_link_paste#markdown#paste']()
    end)
    return true
  end
end

return mod
