return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { [[<C-\>]], "<cmd>ToggleTerm<CR>", mode = { "n", "i", "t" }, desc = "Toggle terminal" },
    { "<D-j>", "<cmd>ToggleTerm<CR>", mode = { "n", "i", "t" }, desc = "Toggle terminal" },
    { "<leader>zf", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal float" },
    { "<leader>zh", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal bottom" },
    { "<leader>zv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Terminal vertical" },
    { "<leader>zt", "<cmd>ToggleTerm direction=tab<CR>", desc = "Terminal tab" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.45)
      end

      if term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end

      return 16
    end,
    open_mapping = [[<C-\>]],
    direction = "float",
    shade_terminals = true,
    start_in_insert = true,
    persist_size = true,
    persist_mode = true,
    close_on_exit = true,
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
  },
}
