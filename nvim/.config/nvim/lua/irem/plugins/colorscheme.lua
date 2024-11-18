return {
    "catppuccin/nvim",
    name = "catppuchin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            transparent_background = true
        })
        vim.cmd([[colorscheme catppuccin-macchiato]])
    end,
}

