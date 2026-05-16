return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local parser_by_filetype = {
        javascriptreact = { "tsx" },
        markdown = { "markdown", "markdown_inline" },
        sh = { "bash" },
        typescriptreact = { "tsx" },
        zsh = { "bash" },
      }

      vim.api.nvim_create_user_command("TSInstallCurrent", function()
        local filetype = vim.bo.filetype
        if filetype == "" then
          vim.notify("No filetype detected for current buffer", vim.log.levels.WARN)
          return
        end

        local parsers = parser_by_filetype[filetype] or { filetype }
        require("nvim-treesitter").install(parsers)
        vim.notify("Installing Tree-sitter parser: " .. table.concat(parsers, ", "))
      end, {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "go",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
