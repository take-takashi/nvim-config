return {
  {
    "kokusenz/deltaview.nvim",
    dependencies = {
      "kokusenz/delta.lua",
    },
    config = function()
      local delta_treesitter = require("delta.utils_treesitter")
      local get_treesitter_highlight_captures = delta_treesitter.get_treesitter_highlight_captures
      local get_treesitter_token_strings = delta_treesitter.get_treesitter_token_strings

      -- Treesitter parser が無い言語では構文ハイライトだけ諦める
      -- diff 自体の行・単語ハイライトは維持して、Delta 表示を落とさない
      delta_treesitter.get_treesitter_highlight_captures = function(text, lang)
        local ok, captures = pcall(get_treesitter_highlight_captures, text, lang)
        if ok then
          return captures
        end
        return {}
      end

      delta_treesitter.get_treesitter_token_strings = function(text, lang)
        local ok, tokens = pcall(get_treesitter_token_strings, text, lang)
        if ok then
          return tokens
        end
        return delta_treesitter.get_lua_pattern_token_strings(text)
      end

      require("deltaview").setup({
        fzf_picker = "telescope",
        line_numbers = true,
        keyconfig = {
          dm_toggle_keybind = "",
          dv_toggle_keybind = "",
          d_toggle_keybind = "",
          next_hunk = "<Tab>",
          prev_hunk = "<S-Tab>",
          next_diff = "]f",
          prev_diff = "[f",
          help_legend = "d?",
        },
      })
    end,
  },
}
