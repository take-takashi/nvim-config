-- <leader> 系のキーマップは which-key-config.lua に集中させる
-- ここに直接追加する場合は、再帰マッピングなし・実行メッセージなしを基本にする

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<C-j>", "<C-d>", opts)
vim.keymap.set("n", "<C-k>", "<C-u>", opts)
