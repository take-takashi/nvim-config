local M = {}

local function filetypes()
  local items = vim.fn.getcompletion("", "filetype")
  table.sort(items)
  table.insert(items, 1, "")
  return items
end

local function display_name(filetype)
  if filetype == "" then
    return "none"
  end
  if filetype == vim.bo.filetype then
    return filetype .. "  (current)"
  end
  return filetype
end

function M.open()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local config = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Filetype",
    finder = finders.new_table({
      results = filetypes(),
      entry_maker = function(filetype)
        return {
          value = filetype,
          display = display_name(filetype),
          ordinal = filetype == "" and "none" or filetype,
        }
      end,
    }),
    sorter = config.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.bo.filetype = selection.value
        vim.notify("filetype=" .. display_name(selection.value), vim.log.levels.INFO)
      end)
      return true
    end,
  }):find()
end

return M
