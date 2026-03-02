local wk = require("which-key")

local telescope = require("telescope.builtin")
local gitgraph = require('gitgraph')

wk.add({
  { "<leader>e", group = "Explorer" }, -- group
  { "<leader>ef", "<cmd>Neotree focus<CR>", desc = "Neotree focus" },
  { "<leader>es", "<cmd>Neotree show<CR>", desc = "Neotree show" },
  { "<leader>ec", "<cmd>Neotree close<CR>", desc = "Neotree close" },
  { "<leader>et", "<cmd>Neotree toggle<CR>", desc = "Neotree toggle" },
  { "<leader>f", group = "Telescope" }, -- group
  { "<leader>ff", telescope.find_files, desc = "Telescope find files" },
  { "<leader>fg", telescope.live_grep, desc = "Telescope live grep" },
  { "<leader>fb", telescope.buffers, desc = "Telescope buffers" },
  { "<leader>fh", telescope.help_tags, desc = "Telescope help tags" },
  { "<leader>g", group = "Git" }, -- group
  { "<leader>gc", telescope.git_commits, desc = "Telescope git commits" },
  { "<leader>gs", telescope.git_status, desc = "Telescope git status" },
  { "<leader>gb", telescope.git_branches, desc = "Telescope git branches" },
  { "<leader>gg", function() gitgraph.draw({}, { all = true, max_count = 5000 }) end, desc = "Git Graph"}
})
