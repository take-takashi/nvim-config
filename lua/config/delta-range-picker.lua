local M = {}

local function current_dir()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir ~= "" and vim.fn.isdirectory(file_dir) == 1 then
    return file_dir
  end
  return vim.fn.getcwd()
end

local function run(args, cwd)
  local result = vim.system(args, { cwd = cwd, text = true }):wait()
  return result.code, result.stdout or "", result.stderr or ""
end

local function output_lines(output)
  if output == "" then
    return {}
  end

  local lines = vim.split(output, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  return lines
end

local function git_root()
  local code, stdout = run({ "git", "rev-parse", "--show-toplevel" }, current_dir())
  if code ~= 0 then
    return nil
  end
  return vim.trim(stdout)
end

local function recent_commits(root)
  local code, stdout, stderr = run({ "git", "log", "--format=%ct%x1f%H%x1f%h%x1f%s", "-n", "100" }, root)
  if code ~= 0 then
    vim.notify(vim.trim(stderr), vim.log.levels.ERROR)
    return {}
  end

  local commits = {}
  for _, line in ipairs(output_lines(stdout)) do
    local parts = vim.split(line, "\31", { plain = true })
    if #parts >= 4 then
      table.insert(commits, {
        timestamp = tonumber(parts[1]) or 0,
        hash = parts[2],
        short_hash = parts[3],
        subject = parts[4],
      })
    end
  end
  return commits
end

local function selected_commits(prompt_bufnr)
  local action_state = require("telescope.actions.state")

  local picker = action_state.get_current_picker(prompt_bufnr)
  local selections = picker:get_multi_selection()
  if #selections == 0 then
    local selection = action_state.get_selected_entry()
    if selection then
      selections = { selection }
    end
  end
  return vim.tbl_map(function(selection)
    return selection.value
  end, selections)
end

local function open_delta_range(commits)
  if #commits ~= 2 then
    vim.notify("Select exactly 2 commits with <Tab>", vim.log.levels.WARN)
    return
  end

  table.sort(commits, function(left, right)
    return left.timestamp < right.timestamp
  end)

  local older = commits[1]
  local newer = commits[2]
  vim.cmd("Delta . 10 " .. older.hash .. ".." .. newer.hash)
end

function M.open()
  local root = git_root()
  if not root then
    vim.notify("Git repository was not found", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local config = require("telescope.config").values
  local actions = require("telescope.actions")

  pickers.new({}, {
    prompt_title = "Delta Commit Range",
    finder = finders.new_table({
      results = recent_commits(root),
      entry_maker = function(commit)
        local display = string.format("%s %s", commit.short_hash, commit.subject)
        return {
          value = commit,
          display = display,
          ordinal = display,
        }
      end,
    }),
    sorter = config.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local commits = selected_commits(prompt_bufnr)
        actions.close(prompt_bufnr)
        open_delta_range(commits)
      end)
      return true
    end,
  }):find()
end

return M
