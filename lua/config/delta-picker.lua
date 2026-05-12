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
local function add_entry(entries, display, command)
  table.insert(entries, {
    display = display,
    command = command,
  })
end

-- 差分の見方をひとつのリストにまとめる
-- files は DeltaMenu でファイル選択、all と commit は Delta で全ファイル表示にする
local function picker_entries(root)
  local entries = {}
  local base = default_base(root)

  add_entry(entries, "files  | working tree", "DeltaMenu")
  add_entry(entries, "all    | working tree", "Delta . 10")
  add_entry(entries, "files  | staged", "DeltaMenu --cached")
  add_entry(entries, "all    | HEAD commit", "Delta . 10 HEAD^!")
  add_entry(entries, "files  | " .. base .. "...HEAD", "DeltaMenu " .. base .. "...HEAD")
  add_entry(entries, "all    | " .. base .. "...HEAD", "Delta . 10 " .. base .. "...HEAD")

  for _, commit in ipairs(recent_commits(root)) do
    add_entry(
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
        vim.cmd(selection.value.command)
      end)
      return true
    end,
  }):find()
end

return M
