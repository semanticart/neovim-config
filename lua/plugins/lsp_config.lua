return {
    {
        'neovim/nvim-lspconfig',

        dependencies = {{'folke/neodev.nvim', 'vim-ruby/vim-ruby'}},

        config = function()
            -- this has to happen before lspconfig
            require("neodev").setup({})

            local on_attach = require'lsp_config_settings'.on_attach
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- local setup_tailwind = function()
            --     capabilities.textDocument.colorProvider = {
            --         dynamicRegistration = true
            --     }
            --     require("lspconfig").tailwindcss.setup({
            --         on_attach = on_attach,
            --         capabilities = capabilities
            --     })
            -- end
            -- setup_tailwind()

            local function organize_imports()
                local params = {
                    command = "_typescript.organizeImports",
                    arguments = {vim.api.nvim_buf_get_name(0)},
                    title = ""
                }
                vim.lsp.buf.execute_command(params)
            end

            require("lspconfig").tsserver.setup {
                on_attach = on_attach,
                cmd = {
                    '/Users/ship/.bun/bin/typescript-language-server', '--stdio'
                },
                -- taken from https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
                init_options = {
                    preferences = {
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true
                    }
                },
                commands = {
                    OrganizeImports = {
                        organize_imports,
                        description = "Organize Imports"
                    }
                }
            }

            -- require'lspconfig'.solargraph.setup {
            --     on_attach = on_attach,
            --     settings = {solargraph = {diagnostics = true}}
            -- }

            require'lspconfig'.lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        hint = {enable = true},
                        completion = {callSnippet = "Replace"},
                        workspace = {checkThirdParty = false},
                        diagnostics = {globals = {'vim'}}
                    }
                }
            })

            require'lspconfig'.marksman.setup {}

            -- textDocument/diagnostic support until 0.10.0 is released
            _timers = {}
            local function setup_diagnostics(client, buffer)
                if require("vim.lsp.diagnostic")._enable then
                    return
                end

                local diagnostic_handler = function()
                    local params = vim.lsp.util
                                       .make_text_document_params(buffer)
                    client.request("textDocument/diagnostic",
                                   {textDocument = params},
                                   function(err, result)
                        if err then
                            local err_msg = string.format(
                                                "diagnostics error - %s",
                                                vim.inspect(err))
                            vim.lsp.log.error(err_msg)
                        end
                        local diagnostic_items = {}
                        if result then
                            diagnostic_items = result.items
                        end
                        vim.lsp.diagnostic.on_publish_diagnostics(nil,
                                                                  vim.tbl_extend(
                                                                      "keep",
                                                                      params, {
                                diagnostics = diagnostic_items
                            }), {client_id = client.id})
                    end)
                end

                diagnostic_handler() -- to request diagnostics on buffer when first attaching

                vim.api.nvim_buf_attach(buffer, false, {
                    on_lines = function()
                        if _timers[buffer] then
                            vim.fn.timer_stop(_timers[buffer])
                        end
                        _timers[buffer] =
                            vim.fn.timer_start(200, diagnostic_handler)
                    end,
                    on_detach = function()
                        if _timers[buffer] then
                            vim.fn.timer_stop(_timers[buffer])
                        end
                    end
                })
            end

            -- adds ShowRubyDeps command to show dependencies in the quickfix list.
            -- add the `all` argument to show indirect dependencies as well
            local function add_ruby_deps_command(client, bufnr)
                vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps",
                                                     function(opts)

                    local params = vim.lsp.util.make_range_params()

                    local showAll = opts.args == "all"

                    client.request("rubyLsp/workspace/dependencies", params,
                                   function(error, result)
                        if error then
                            print("Error showing deps: " .. error)
                            return
                        end

                        local qf_list = {}
                        for _, item in ipairs(result) do
                            if showAll or item.dependency then
                                table.insert(qf_list, {
                                    text = string.format("%s (%s) - %s",
                                                         item.name,
                                                         item.version,
                                                         item.dependency),

                                    filename = item.path
                                })
                            end
                        end

                        vim.fn.setqflist(qf_list)
                        vim.cmd('copen')
                    end, bufnr)
                end, {nargs = "?", complete = function()
                    return {"all"}
                end})
            end

            require("lspconfig").ruby_ls.setup({
                on_attach = function(client, buffer)
                    setup_diagnostics(client, buffer)
                    add_ruby_deps_command(client, buffer)
                end
            })
        end
    }
}
