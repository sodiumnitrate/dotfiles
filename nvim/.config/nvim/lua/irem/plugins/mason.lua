-- based on kickstart
return {
    'neovim/nvim-lspconfig',
    dependencies = {
        {'williamboman/mason.nvim', config = true},
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- useful status updaes for lsp
        -- opts = {} is equivalent to require('fidget').setup({})
        { 'j-hui/fidget.nvim', opts = {} },

        -- allows extra capabilities provided by nvim-cmp
        'hrsh7th/cmp-nvim-lsp',
    },

    config = function()
        -- function to call when an LSP attaches to a buffer
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                -- function that lets us define mappings specific for LSP related items
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                -- rename the variable under your cursor
                map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                -- execute a code action or suggestion from LSP
                map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', {'n', 'x'})

                -- go to declaration
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                -- highlight references of the word under your cursor when your cursor rests there for a bit
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {clear = false})
                    vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end

                -- keymaps to toggle inlay hints in code
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map('<leader>th', function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {bufnr = event.buf})
                    end, '[T]oggle Inlay [H]ints')
                end
            end,
        })

        -- create new capabilities with nvim cmp and broadcast to the servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        -- enable the following language servers
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                    },
                },
            },

            pyright = {
                cmd = {"pyright-langserver", "--stdio"},
                filetypes = {"python"},
                -- capabilities = {},
                settings = {
                   analysis = {
                       autoSearchPaths = true,
                       diagnosticMode = "openFilesOnly",
                       useLibraryCodeForTypes = true
                   } 
                }
            },

            clangd = {
                cmd = {"clangd"},
                capabilities = {
                    offsetEncoding = {"utf-8", "utf-16"},
                    textDocument = {
                        completion = {
                            editsNearCursor = true
                        }
                    }
                },
                filetypes = {"c", "cpp", "objc", "objcpp", "cuda", "proto"},
                single_file_support = true
            },

            cmake = {
                cmd = {'cmake-language-server'},
                filetypes = {"cmake"},
                init_options = {buildDirectory = "build"},
                single_file_support = true
            },

            marksman = {
                cmd = {"marksman", "server"},
                filetypes = {"markdown", "markdown.mdx"},
                single_file_support = true
            },

            -- nextflow_ls = {
                -- cmd = {"java", "-jar", "nextflow-language-server-all.jar"},
                -- filetypes = {"nextflow"},
                -- settings = {
                    -- nextflow = {
                        -- files = {
                            -- exclude = {".git", ".nf-test", "work"}
                        -- }
                    -- }
                -- }
            -- },


        }

        -- ensure the servers and tools above are installed
        -- Check with
        --      :Mason
        -- press g? for help
        require('mason').setup()

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            'stylua', -- used to format lua code
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- handles overriding only values explicitly passed
                    -- by the server config. useful when disabling certain feats
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        }
    end,
}

