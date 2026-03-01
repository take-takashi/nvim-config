-- Bootstrap lazy.nvim
-- 公式のものをそのまま利用
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
-- 公式から設定を少し変更
require("lazy").setup({
  spec = {
    -- import your plugins
    -- pluginsフォルダを参照する
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- 未インストールのものは自動でインストールする
  install = { missing = true },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
  checker = { enabled = false },
  -- 変更通知しない
  change_detection = { notify = false },
})