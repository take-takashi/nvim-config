local wk = require("which-key")

wk.add({
  { "<leader>e", group = "Explorer"}, -- group
  { "<leader>ef", "<cmd>Neotree focus<CR>", desc = "Neotree focus"},
  { "<leader>es", "<cmd>Neotree show<CR>", desc = "Neotree show"},
  { "<leader>ec", "<cmd>Neotree close<CR>", desc = "Neotree close"},
  { "<leader>et", "<cmd>Neotree toggle<CR>", desc = "Neotree toggle"},
})
