return {
  {
    "delphinus/md-render.nvim",
    version = "*",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", version = "*" },
      { "delphinus/budoux.lua", version = "*" },
    },
    ft = { "markdown" },
    cmd = "MdRender",
  },
}
