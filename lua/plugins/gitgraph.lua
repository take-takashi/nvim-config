return {
  'isakbm/gitgraph.nvim',
  dependencies = {
      "sindrets/diffview.nvim", -- 任意（差分表示強化）
  },
  cmd = {},
  opts = {
    format = {
      timestamp = '%Y-%m-%d %H:%M:%S',
      fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
    },
    hooks = {
      on_select_commit = function(commit)
        print('selected commit:', commit.hash)
      end,
      on_select_range_commit = function(from, to)
        print('selected range:', from.hash, to.hash)
      end,
    },
    symbols = {
      merge_commit = '',
      commit = '',
      merge_commit_end = '',
      commit_end = '',

      -- Advanced symbols
      GVER = '',
      GHOR = '',
      GCLD = '',
      GCRD = '╭',
      GCLU = '',
      GCRU = '',
      GLRU = '',
      GLRD = '',
      GLUD = '',
      GRUD = '',
      GFORKU = '',
      GFORKD = '',
      GRUDCD = '',
      GRUDCU = '',
      GLUDCD = '',
      GLUDCU = '',
      GLRDCL = '',
      GLRDCR = '',
      GLRUCL = '',
      GLRUCR = '',
    },
  },
}