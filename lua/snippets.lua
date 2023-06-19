local map = require("helpers").map
local ls = require("luasnip")
local ps = ls.parser.parse_snippet
local f = ls.function_node
local c = ls.c
local s = ls.s
local i = ls.i
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local same = function(index) return
    f(function(args) return args[1] end, {index}) end

local prefixSameCamel = function(index, prefix)
    return f(function(args)
        return prefix .. (args[1][1]:gsub("^%l", string.upper))
    end, {index})
end

local todo_choices = function(position)
    local username = "semanticart"
    return d(position, function()
        return sn(nil, c(1, {
            t("TODO(" .. username .. "): "), t("FIXME(" .. username .. "): "),
            t("NOTE(" .. username .. "): ")
        }))
    end)
end

-- important!! Having the sn(...) as the first choice will cause infinite recursion.
local NO_INFINITE_RECURSION = function() return t("") end

local ruby_when_choice
ruby_when_choice = function()
    return sn(nil, {
        c(1, {
            NO_INFINITE_RECURSION(), sn(nil, {
                t({"", "  when "}), i(1), t({"", "  "}), i(2),
                d(3, ruby_when_choice, {})
            }, t("end"))
        })
    });
end

ls.add_snippets("all", {
    s("today", f(
          function()
            return vim.fn.strftime('%Y-%m-%d', vim.fn.localtime())
        end, {}))
})

ls.add_snippets("lua", {
    s("req", fmt([[local {} = require("{}")]], {
        f(function(import_name)
            local parts = vim.split(import_name[1][1], ".", true)
            return parts[#parts] or ""
        end, {1}), i(1)
    })), s("todo", fmt("-- {}", {todo_choices(1)}))
})

ls.add_snippets("elixir", {
    ps("p", "IO.inspect($1)"), ps("caller",
                                  "IO.inspect(Process.info(self(), :current_stacktrace), label: \"STACKTRACE\")"),
    s("todo", fmt("# {}", {todo_choices(1)}))
})

local available_factories = function(position)
    local factories = {}
    return d(position, function()
        if vim.tbl_isempty(factories) then
            local cmd =
                'rails runner "FactoryBot.factories.map { |f| puts f.name }" 2>/dev/null'

            -- TODO: FactoryBot.factory_by_name(NAME_AS_STRING).defined_traits

            factories = vim.fn.systemlist(cmd)
        end

        return sn(nil, {c(1, map(factories, t))})
    end)
end

local allow_receive_options = {
    t(""), t(".and_call_original"),
    fmta(" { <> }", {i(1, ":return_value")}, {dedent = false}),
    fmt(".and_return({})", {i(1, ":return_value")}),
    fmta(".with(<>) { <> }", {i(1, "args"), i(2, ":return_value")}),
    fmt(".and_raise({})", {i(1, ":error")}),
    fmt(".and_throw({})", {i(1, ":error")}),
    fmt(".and_yield({})", {i(1, "args")})
}

local allow = s("allow", fmt([[
    allow({}).to receive({}){}

    expect({}).to have_received({}).with({})
    ]], {
    i(1, "obj"), i(2, ":method"), c(3, allow_receive_options), same(1), same(2),
    i(4, "args")
}))

ls.add_snippets("ruby", {
    s("todo", fmt("# {}", {todo_choices(1)})), ps("db", "debugger"), ps("fout",
                                                                        "File.open('/tmp/out.html', 'w') { |f| f.print response.body }; `open /tmp/out.html`"), -- write html response to file and open it
    ps("it", "it \"$1\" do\n  $2\nend$0"),
    ps("desc", "describe \"$1\" do\n  $2\nend$0"),
    ps("fc", "FactoryBot.create(:$1)"), s("case", {
        t("case "), i(1), t({"", "when "}), i(2), t({"", "  "}), i(3),
        d(4, ruby_when_choice, {}), t({"", "end"}), i(0)
    }), s("p", {
        c(1, {
            t("puts \"#{__FILE__} @ #{__LINE__}\""),
            sn(nil, {i(1), t("Rails.logger.info "), i(2)}),
            sn(nil, {i(1), t("Rails.logger.error "), i(2)})
        }), i(2)
    }), s("fb", {
        t("FactoryBot."), c(1, {t("create"), t("build")}), t("(:"),
        available_factories(2), t(")")
    }), ps("astats",
           "require 'allocation_stats'\nstats = ::AllocationStats.trace do\n\nend\n\nputs stats.allocations(alias_paths: true).group_by(:sourcefile, :class).to_text"),
    allow
})

ls.add_snippets('eruby', {
    s('=', {t('<%= '), i(1), t(' %>'), i(0)}),
    s('<', {t('<% '), i(1), t(' %>'), i(0)}), s('end', {t('<% end %>')})
})

ls.add_snippets("javascript", {
    ps("for", "for (let i = 0; i < $1; i++) { $2 }"), ps("switch",
                                                         "switch($1) {\n  case $2:\n    $3\nbreak;\n\ndefault:\n    $4\nbreak;\n}"),
    s("state", fmt([[
    const [{}, {}] = useState({});
    ]], {i(1, "value"), prefixSameCamel(1, "set"), i(2, "defaultValue")})),
    ps("effect", "useEffect(() => {\n  $1\n}, [${2:cacheArgs}]);$0"),
    ps("ref", "const ${1:refContainer} = useRef($2);"),
    ps("it", "it(\"$1\", () => {\n  $2\n});$0"),
    ps("desc", "describe(\"$1\", () => {\n  $2\n});$0"),
    ps("beforeeach", "beforeEach(() => {\n$1\n});$0"),
    s("todo", fmt("// {}", {todo_choices(1)})), ps("p", "console.log($1)"),
    ps("pp", "console.log({$1})"),
    ps("burn-in", "for (var i = 0; i < 10; i++) {"),
    ps("move", "// TODO: move this"), ps("rename", "// TODO: rename this"),
    ps("pj", "console.log(JSON.stringify($1, null, 2))")
})

ls.add_snippets("rust", {
    ps("p", 'println!("{:?}", $1);$0'),
    ps("pexit", 'eprintln!("Application error: {}", e);\nprocess::exit(1);'),
    ps("#test",
       '#[cfg(test)]\nmod tests {\n\tuse super::*;\n\n\t#[test]\n\tfn $1() {\n\t\t$2\n\t}\n}'),
    ps("test", '#[test]\nfn $1() {\n\t$2\n}'), ps("#debug", '#[derive(Debug)]')
})

ls.add_snippets("markdown", {
    ps("[", "[${1:description}](${2:url})$0"),
    ps("det", "<details>\n\t<summary>$1</summary>\n\n$2\n</details>"),
    ps("tags", "---\ntags:\n  - $1\n---")
})

-- only used when reloading
if ls.config.config then ls.config.set_config(ls.config.config) end

-- e.g.
-- require("luasnip").snip_expand(snippet_by_trigger("refactor", "ruby"), {})
local snippet_by_trigger = function(trigger, type)
    local match

    for _, snippet in ipairs(ls.get_snippets()[type]) do
        if snippet.trigger == trigger then match = snippet end
    end

    return match
end

vim.keymap.set('i', '<a-u>',
               '<cmd>lua require("luasnip.extras.select_choice")()<CR>',
               {buffer = 0})
vim.keymap.set('i', '<a-q>', '<cmd>lua require("luasnip").unlink_current()<CR>',
               {buffer = 0})

local au_group = vim.api.nvim_create_augroup("MySnippets", {clear = true})
vim.api.nvim_create_autocmd({"BufWritePost"}, {
    desc = "Reload snippets",
    pattern = "*/snippets.lua",
    callback = function()
        ls.cleanup()
        vim.cmd("luafile " .. vim.fn.expand('%'))
    end,
    group = au_group
})
