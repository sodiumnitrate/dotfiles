return {
    'sevearc/conform.nvim',
    event = {'BufWritePre'},
    cmd = {'ConformInfo'},
    keys = {
        {
            '<leader>f',
            function()
                require('conform').format { async = true, lsp_format = 'fallback'}
            end,
            mode = '',
            desc = '[F]ormat buffer',
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            -- disable on for languages that don't have good support
            local disable_filetypes = { c = true, cpp = true}
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
                lsp_format_opt = 'never'
            else
                lsp_format_opt = 'fallback'
            end
            return {
                timeout_ms = 500,
                lsp_formatt = lsp_format_opt,
            }
        end,
        formatters_by_ft = {
            lua = {'stylua'},
            python = {'isort', 'black'}
        },
    },
}
