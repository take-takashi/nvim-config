local wk = require("which-key")

local telescope = require("telescope.builtin")
local gitgraph = require('gitgraph')

wk.add({
  { mode = "n", silent = true },
  { "<leader><Left>", "<C-w>h", desc = "Window left" },
  { "<leader><Down>", "<C-w>j", desc = "Window down" },
  { "<leader><Up>", "<C-w>k", desc = "Window up" },
  { "<leader><Right>", "<C-w>l", desc = "Window right" },
  { "<leader>e", group = "Explorer" }, -- group
  { "<leader>ee", "<cmd>Neotree reveal<CR>", desc = "Neotree reveal" },
  { "<leader>ef", "<cmd>Neotree focus<CR>", desc = "Neotree focus" },
  { "<leader>es", "<cmd>Neotree show<CR>", desc = "Neotree show" },
  { "<leader>ec", "<cmd>Neotree close<CR>", desc = "Neotree close" },
  { "<leader>et", "<cmd>Neotree toggle<CR>", desc = "Neotree toggle" },
  { "<leader>f", group = "Telescope" }, -- group
  { "<leader>ff", telescope.find_files, desc = "Telescope find files" },
  { "<leader>fg", telescope.live_grep, desc = "Telescope live grep" },
  { "<leader>fb", telescope.buffers, desc = "Telescope buffers" },
  { "<leader>fd", function() require("config.delta-picker").open() end, desc = "Telescope git diff" },
  { "<leader>fh", telescope.help_tags, desc = "Telescope help tags" },
  { "<leader>fc", group = "Filetype" },
  { "<leader>fcc", function() require("config.filetype-picker").open() end, desc = "Change current buffer filetype" },
  { "<leader>m", group = "Markdown" }, -- group
  { "<leader>mp", "<cmd>MdRender auto on<CR>", desc = "Markdown auto preview" },
  { "<leader>mt", "<Plug>(md-render-preview-tab)", desc = "Markdown preview tab" },
  { "<leader>ms", "<cmd>MdRender split<CR>", desc = "Markdown preview split" },
  { "<leader>md", "<Plug>(md-render-demo)", desc = "Markdown render demo" },
  { "<leader>t", group = "Tree-sitter" }, -- group
  { "<leader>ti", "<cmd>TSInstallCurrent<CR>", desc = "Tree-sitter install current parser" },
  { "<leader>g", group = "Git" }, -- group
  { "<leader>gc", telescope.git_commits, desc = "Telescope git commits" },
  { "<leader>gs", telescope.git_status, desc = "Telescope git status" },
  { "<leader>gb", telescope.git_branches, desc = "Telescope git branches" },
  { "<leader>gg", function() gitgraph.draw({}, { all = true, max_count = 5000 }) end, desc = "Git Graph"},
  { "<leader>gD", function() require("config.delta-range-picker").open() end, desc = "Git commit range diff" },
  { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git diff view" },
  { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git file history" },
  { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Git repo history" },
})
