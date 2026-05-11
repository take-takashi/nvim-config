vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- システムクリップボードを使用
vim.opt.clipboard:append({"unnamedplus"})
-- 行番号を表示
vim.opt.number = true
-- カーソルラインを表示
vim.opt.cursorline = true
-- カーソルの左右移動で行をまたいで移動できるようにする
-- <  : 行頭で左に移動すると前の行の末尾へ移動
-- >  : 行末で右に移動すると次の行の先頭へ移動
-- [ ]: ← → キーでも行またぎ移動を許可
-- h l: ノーマルモードの h / l でも同様に行またぎ移動を許可
vim.opt.whichwrap = "<,>,[,],h,l"

-- 背景色はターミナル側に任せる
local function use_terminal_background()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
end

use_terminal_background()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = use_terminal_background,
})
