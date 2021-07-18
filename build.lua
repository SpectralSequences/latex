module = "spectralsequences"

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
    for line in string.gmatch(new_content, "([^\n]*)\n") do
        if pattern then
            if line == "END_EXPECT_THROWS" then
                output = handle_expect_block(cur_expect_block, pattern)
                result = result .. output .. os_newline
                pattern = nil
                cur_expect_block = ""
            else
                cur_expect_block = cur_expect_block .. line .. os_newline
            end
        else
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
    if not string.match(line, "^[.]+\\") then
        return nil
    end
    line = string.gsub(line, "[(][0-9.]*pt too [a-z]*[)]", "")
    return line
end

function handle_expect_block(expect_block, pat)
    if string.match(expect_block, pat) then
        return "expect match succeeded: pattern '" .. pat .. "' was found."
    else
        print("!!!!!!!!!!!!!!!!!!\n")
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
