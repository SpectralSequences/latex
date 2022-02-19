module = "spectralsequences"

require("l3build_funcs")

sourcefiledir = "src"
docfiledir    = "manual"
installfiles = { "*.sty", "*.code.tex" }
sourcefiles = { "*.*" }
testfiledir = "./tests"
textfiles = { "*.tex" }
-- typesetfiles  = {"spectralsequencesmanual.tex"}
packtdszip    = true

if os.getenv("TEXLIVE_VERSION") < "2020" then
    specialformats = { latex = { luatex = { binary = "luatex",format = "lualatex" } } }
end

function my_rewrite_log(source, result, engine, errlevels)
  return rewrite(source, result, my_normalize_log, engine, errlevels)
end

function my_normalize_log(content, engine, errlevels)
	local new_content = normalize_log(content, engine, errlevels)
    local result = ""
    local pattern = nil
    local cur_expect_block = ""
    local test_num = ""
    local test_name = ""
    for line in string.gmatch(new_content, "([^\n]*)\n") do
        if pattern then
            if line == "END_EXPECT_THROWS" then
                output = handle_expect_block(cur_expect_block, pattern, test_num, test_name)
                result = result .. output .. os_newline
                pattern = nil
                cur_expect_block = ""
            else
                cur_expect_block = cur_expect_block .. line .. os_newline
            end
        else
            local num, name = string.match(line, "TEST ([0-9]*): (.*)")
            if num then 
                test_num = num test_name = name
            end
            pattern = string.match(line, "EXPECT_THROWS::(.*)::$")
            if not pattern then
                line = clean_line(line)
                if line then
                    result = result .. line .. os_newline
                end
            end
        end

    end
	return result
end

function clean_line(line)
    if string.match(line, "^[.]+\\") then
        return nil
    end
    if string.match(line, "^%[%]%[%]") then
        return nil
    end
    if string.match(line, "^[0-9.]* ?c? ?[\\ETC]* ?}") then
        return nil
    end
    line = string.gsub(line, "[(][0-9.]*pt too [a-z]*[)]", "")
    return line
end

function handle_expect_block(expect_block, pat, test_num, test_name)
    if string.match(expect_block, pat) then
        return "expect match succeeded: pattern '" .. pat .. "' was found."
    else
        print("!!!!!!!!!!!!!!!!!!\n")
        print("In test " .. test_num .. ": " .. test_name)
        print("expect match failed: pattern '" .. pat .. "' not found in block:")
        print("")
        print(expect_block)
        print("!!!!!!!!!!!!!!!!!!\n")
        return "expect match failed: pattern '" .. pat .. "' not found."
    end
end


bakext = bakext or ".bak"
dviext = dviext or ".dvi"
logext = logext or ".log"
lveext = lveext or ".lve"
lvtext = lvtext or ".lvt"
pdfext = pdfext or ".pdf"
psext  = psext  or ".ps"
pvtext = pvtext or ".pvt"
tlgext = tlgext or ".tlg"
tpfext = tpfext or ".tpf"

test_types = { log = {
    test = lvtext,
    generated = logext,
    reference = tlgext,
    expectation = lveext,
    compare = compare_tlg,
    rewrite = my_rewrite_log,
}}
