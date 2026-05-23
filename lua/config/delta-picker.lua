local M = {}

-- 現在のバッファがファイルならそのディレクトリを起点にする
-- ファイルでない画面では Neovim の cwd を起点にする
local function current_dir()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir ~= "" and vim.fn.isdirectory(file_dir) == 1 then
    return file_dir
  end
  return vim.fn.getcwd()
end

-- git コマンドは shell を経由せず、引数配列で実行する
-- 呼び出し側は終了コード・標準出力・標準エラーを見て扱いを決める
local function run(args, cwd)
  local result = vim.system(args, { cwd = cwd, text = true }):wait()
  return result.code, result.stdout or "", result.stderr or ""
end

-- git の標準出力を Lua の配列に変換する
-- 最後の空行は picker の空項目にならないように捨てる
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

-- 今いる場所から Git repository の root を探す
-- 見つからない場合は picker を開かずに警告する
local function git_root()
  local code, stdout = run({ "git", "rev-parse", "--show-toplevel" }, current_dir())
  if code ~= 0 then
    return nil
  end
  return vim.trim(stdout)
end

-- main 相当の比較先を origin/HEAD から推測する
-- origin/HEAD が無い repository では origin/main を使う
local function default_base(cwd)
  local code, stdout = run({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, cwd)
  if code == 0 and stdout ~= "" then
    return vim.trim(stdout)
  end
  return "origin/main"
end

-- git worktree list --porcelain の block 形式を扱いやすい table に変換する
local function worktrees(root)
  local code, stdout, stderr = run({ "git", "worktree", "list", "--porcelain" }, root)
  if code ~= 0 then
    vim.notify(vim.trim(stderr), vim.log.levels.WARN)
    return {}
  end

  local items = {}
  local current = nil
  for _, line in ipairs(output_lines(stdout)) do
    if line:match("^worktree ") then
      if current then
        table.insert(items, current)
      end
      current = {
        path = line:gsub("^worktree ", ""),
      }
    elseif current and line:match("^HEAD ") then
      current.head = line:gsub("^HEAD ", "")
    elseif current and line:match("^branch ") then
      current.branch = line:gsub("^branch refs/heads/", ""):gsub("^branch ", "")
    elseif current and line == "detached" then
      current.detached = true
    end
  end

  if current then
    table.insert(items, current)
  end

  return items
end

local function same_path(a, b)
  local real_a = vim.uv.fs_realpath(a) or a
  local real_b = vim.uv.fs_realpath(b) or b
  return real_a == real_b
end

local function worktree_label(wt)
  if wt.branch and wt.branch ~= "" then
    return wt.branch
  end
  if wt.head and wt.head ~= "" then
    return "detached:" .. wt.head:sub(1, 7)
  end
  return vim.fn.fnamemodify(wt.path, ":t")
end

local function has_uncommitted(path)
  local code, stdout = run({ "git", "status", "--porcelain" }, path)
  return code == 0 and stdout ~= ""
end

local function upstream_or_default_base(path)
  local code, stdout = run({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" }, path)
  if code == 0 and stdout ~= "" then
    return vim.trim(stdout)
  end
  return default_base(path)
end

local function ahead_count(path, base)
  local code, stdout = run({ "git", "rev-list", "--count", base .. "..HEAD" }, path)
  if code ~= 0 or stdout == "" then
    return 0
  end
  return tonumber(vim.trim(stdout)) or 0
end

local function untracked_files(path)
  local code, stdout = run({ "git", "ls-files", "-o", "--exclude-standard" }, path)
  if code ~= 0 then
    return {}
  end
  return output_lines(stdout)
end

local function diff_output(path, args)
  local command = { "git", "diff", "--full-index", "-U10" }
  vim.list_extend(command, args)
  local code, stdout, stderr = run(command, path)
  if code ~= 0 and code ~= 1 then
    vim.notify(vim.trim(stderr), vim.log.levels.ERROR)
    return nil
  end
  return stdout
end

local function uncommitted_diff(path)
  local chunks = {}
  local tracked = diff_output(path, { "HEAD" })
  if tracked and tracked ~= "" then
    table.insert(chunks, tracked)
  end

  for _, file in ipairs(untracked_files(path)) do
    local untracked = diff_output(path, { "--no-index", "--", "/dev/null", file })
    if untracked and untracked ~= "" then
      table.insert(chunks, untracked)
    end
  end

  return table.concat(chunks, "\n")
end

local function open_patch_diff(diffstring, name)
  if diffstring == nil or vim.trim(diffstring) == "" then
    vim.notify("No changes detected", vim.log.levels.INFO)
    return
  end

  local delta = require("delta")
  local bufnr = delta.patch_diff(diffstring, true, nil, {})
  if bufnr == nil then
    return
  end

  vim.api.nvim_win_set_buf(0, bufnr)
  delta.highlight_delta_artifacts(bufnr)
  delta.syntax_highlight_diff_set(bufnr)
  delta.diff_highlight_diff(bufnr)
  delta.setup_delta_statuscolumn(bufnr)
  vim.api.nvim_buf_set_name(bufnr, "deltaview://diff/" .. name)
end

-- Telescope に並べるため、直近コミットを hash・短縮 hash・件名に分解する
-- 区切り文字には通常のコミット件名に入りにくい unit separator を使う
local function recent_commits(root)
  local code, stdout, stderr = run({ "git", "log", "--format=%H%x1f%h%x1f%s", "-n", "50" }, root)
  if code ~= 0 then
    vim.notify(vim.trim(stderr), vim.log.levels.ERROR)
    return {}
  end

  local commits = {}
  for _, line in ipairs(output_lines(stdout)) do
    local parts = vim.split(line, "\31", { plain = true })
    if #parts >= 3 then
      table.insert(commits, {
        hash = parts[1],
        short_hash = parts[2],
        subject = parts[3],
      })
    end
  end
  return commits
end

-- Telescope の表示名と、選択時に実行する deltaview コマンドを対応づける
local function add_entry(entries, display, action)
  table.insert(entries, {
    display = display,
    action = action,
  })
end

local function add_command_entry(entries, display, command)
  add_entry(entries, display, function()
    vim.cmd(command)
  end)
end

-- 差分の見方をひとつのリストにまとめる
-- files は DeltaMenu でファイル選択、all と commit は Delta で全ファイル表示にする
local function picker_entries(root)
  local entries = {}
  local base = default_base(root)

  add_command_entry(entries, "files  | uncommitted", "DeltaMenu HEAD")
  add_command_entry(entries, "all    | uncommitted", "Delta . 10 HEAD")
  add_command_entry(entries, "all    | HEAD commit", "Delta . 10 HEAD^!")
  add_command_entry(entries, "files  | " .. base .. "...HEAD", "DeltaMenu " .. base .. "...HEAD")
  add_command_entry(entries, "all    | " .. base .. "...HEAD", "Delta . 10 " .. base .. "...HEAD")

  for _, wt in ipairs(worktrees(root)) do
    if not same_path(wt.path, root) then
      local label = worktree_label(wt)

      if has_uncommitted(wt.path) then
        add_entry(entries, "wt     | " .. label .. " | uncommitted", function()
          open_patch_diff(uncommitted_diff(wt.path), "wt/" .. label .. "/uncommitted")
        end)
      end

      local wt_base = upstream_or_default_base(wt.path)
      local count = ahead_count(wt.path, wt_base)
      if count > 0 then
        add_entry(entries, string.format("wt     | %s | %s..HEAD (%d)", label, wt_base, count), function()
          open_patch_diff(
            diff_output(wt.path, { wt_base .. "...HEAD" }),
            "wt/" .. label .. "/" .. wt_base .. "...HEAD"
          )
        end)
      end
    end
  end

  for _, commit in ipairs(recent_commits(root)) do
    add_command_entry(
      entries,
      string.format("commit | %s %s", commit.short_hash, commit.subject),
      "Delta . 10 " .. commit.hash .. "^!"
    )
  end

  return entries
end

-- Telescope で差分の見方を選ばせ、選択された deltaview コマンドを実行する
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
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Delta",
    finder = finders.new_table({
      results = picker_entries(root),
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = config.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        selection.value.action()
      end)
      return true
    end,
  }):find()
end

return M
