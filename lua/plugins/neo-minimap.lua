return {
    {
        'ziontee113/neo-minimap',

        config = function()
            local nm = require("neo-minimap")

            nm.setup_defaults({
                width = 100,
                height = 36,
                height_toggle = {36, 12}
            })

            nm.set({"zi", "za", "zr"}, "*.rb", {
                events = {"BufEnter"},
                query = {
                    [[
                    ;; methods
((method) @cap)
((singleton_method) @cap)
((class) @cap)
((module) @cap)
((identifier) @cap (#vim-match? @cap "^describe"))
((identifier) @cap (#vim-match? @cap "^it"))
  ]], [[
;; attributes
((identifier) @cap (#vim-match? @cap "^argument")) ;; mutation arguments
((identifier) @cap (#vim-match? @cap "^attr"))
((identifier) @cap (#vim-match? @cap "^delegate"))
]], [[
;; relationships
((identifier) @cap (#vim-match? @cap "^has_many"))
((identifier) @cap (#vim-match? @cap "^has_one"))
((identifier) @cap (#vim-match? @cap "^has_and_belongs_to_many"))
((identifier) @cap (#vim-match? @cap "^belongs_to"))
]]

                }
            })

            nm.set({"zi"}, {"*.tsx", "*.ts"}, {
                query = {
                    [[
((export_statement) @cap)
((import_statement) @cap)
((variable_declarator) @cap)
((identifier) @cap (#vim-match? @cap "^describe"))
((identifier) @cap (#vim-match? @cap "^it"))
  ]]
                }
            })

            nm.set("zi", "markdown", {
                query = [[
                ((atx_heading) @cap)
                ]]
            })
        end
    }
}
