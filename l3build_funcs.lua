
local open             = io.open
local close            = io.close
local write            = io.write
local output           = io.output

local len              = string.len
local char             = string.char
local str_format       = string.format
local gmatch           = string.gmatch
local gsub             = string.gsub
local match            = string.match

local utf8_char        = unicode.utf8.char


function normalize_log(content,engine,errlevels)
    local maxprintline = maxprintline
    if (match(engine,"^lua") or match(engine,"^harf")) and luatex_version < 113 then
      maxprintline = maxprintline + 1 -- Deal with an out-by-one error
    end
    local function killcheck(line)
        -- Skip \openin/\openout lines in web2c 7.x
        -- As Lua doesn't allow "(in|out)", a slightly complex approach:
        -- do a substitution to check the line is exactly what is required!
      if match(gsub(line, "^\\openin", "\\openout"), "^\\openout%d%d? = ") then
        return true
      end
      return false
    end
      -- Substitutions to remove some non-useful changes
    local function normalize(line,lastline,drop_fd)
      if drop_fd then
        if match(line," *%)") then
          return "",""
        else
          return "","",true
        end
      end
      -- Zap line numbers from \show, \showbox, \box_show and the like:
      -- do this before wrapping lines
      line = gsub(line, "^l%.%d+ ", "l. ...")
      -- Also from lua stack traces.
      line = gsub(line, "lua:%d+: in function", "lua:...: in function")
      -- Allow for wrapped lines: preserve the content and wrap
      -- Skip lines that have an explicit marker for truncation
      if len(line) == maxprintline  and
         not match(line, "%.%.%.$") then
        return "", (lastline or "") .. line
      end
      line = (lastline or "") .. line
      lastline = ""
      -- Zap ./ at begin of filename
      line = gsub(line, "%(%.%/", "(")
      -- Zap paths
      -- The pattern excludes < and > as the image part can have
      -- several entries on one line
      local pattern = "%w?:?/[^ %<%>]*/([^/%(%)]*%.%w*)"
      -- Files loaded from TeX: all start ( -- )
      line = gsub(line, "%(" .. pattern, "(../%1")
      -- Images
      line = gsub(line, "<" .. pattern .. ">", "<../%1>")
      -- luaotfload files start with keywords
      line = gsub(line, "from " .. pattern .. "%(", "from. ./%1(")
      line = gsub(line, ": " .. pattern .. "%)", ": ../%1)")
      -- Deal with XeTeX specials
      if match(line, "^%.+\\XeTeX.?.?.?file") then
        line = gsub(line, pattern, "../%1")
      end
      -- Deal with dates
      if match(line, "[^<]%d%d%d%d[/%-]%d%d[/%-]%d%d") then
          line = gsub(line,"%d%d%d%d[/%-]%d%d[/%-]%d%d","....-..-..")
          line = gsub(line,"v%d+%.?%d?%d?%w?","v...")
      end
      -- Deal with leading spaces for file and page number lines
      line = gsub(line,"^ *%[(%d)","[%1")
      line = gsub(line,"^ *%(","(")
      -- Zap .fd lines: drop the first part, and skip to the end
      if match(line, "^ *%([%.%/%w]+%.fd[^%)]*$") then
        return "","",true
      end
      -- TeX90/XeTeX knows only the smaller set of dimension units
      line = gsub(line,
        "cm, mm, dd, cc, bp, or sp",
        "cm, mm, dd, cc, nd, nc, bp, or sp")
      -- On the other hand, (u)pTeX has some new units!
      line = gsub(line,
        "em, ex, zw, zh, in, pt, pc,",
        "em, ex, in, pt, pc,")
      line = gsub(line,
        "cm, mm, dd, cc, bp, H, Q, or sp;",
        "cm, mm, dd, cc, nd, nc, bp, or sp;")
      -- Normalise a case where fixing a TeX bug changes the message text
      line = gsub(line, "\\csname\\endcsname ", "\\csname\\endcsname")
      -- Zap "on line <num>" and replace with "on line ..."
      -- Two similar cases, Lua patterns mean we need to do them separately
      line = gsub(line, "on line %d*", "on line ...")
      line = gsub(line, "on input line %d*", "on input line ...")
      -- Tidy up to ^^ notation
      for i = 0, 31 do
        line = gsub(line, char(i), "^^" .. char(64 + i))
      end
      -- Normalise register allocation to hard-coded numbers
      -- No regex, so use a pattern plus lookup approach
      local register_types = {
          attribute      = true,
          box            = true,
          bytecode       = true,
          catcodetable   = true,
          count          = true,
          dimen          = true,
          insert         = true,
          language       = true,
          luabytecode    = true,
          luachunk       = true,
          luafunction    = true,
          marks          = true,
          muskip         = true,
          read           = true,
          skip           = true,
          toks           = true,
          whatsit        = true,
          write          = true,
          XeTeXcharclass = true
        }
      if register_types[match(line, "^\\[^%]]+=\\([a-z]+)%d+$")] then
        line = gsub(line, "%d+$", "...")
      end
      -- Also deal with showing boxes
      if match(line, "^> \\box%d+=$") or match(line, "^> \\box%d+=(void)$") then
        line = gsub(line, "%d+=", "...=")
      end
      if not match(stdengine,"^e?u?ptex$") then
        -- Remove 'normal' direction information on boxes with (u)pTeX
        line = gsub(line, ",? yoko direction,?", "")
        line = gsub(line, ",? yoko%(math%) direction,?", "")
        -- Remove '\displace 0.0' lines in (u)pTeX
        if match(line,"^%.*\\displace 0%.0$") then
          return ""
        end
      end
      -- Deal with Lua function calls
      if match(line, "^Lua function") then
        line = gsub(line,"= %d+$","= ...")
      end
      -- Remove the \special line that in DVI mode keeps PDFs comparable
      if match(line, "^%.*\\special%{pdf: docinfo << /Creator") or
        match(line, "^%.*\\special%{ps: /setdistillerparams") or
        match(line, "^%.*\\special%{! <</........UUID") then
        return ""
      end
      -- Remove \special lines for DVI .pro files
      if match(line, "^%.*\\special%{header=") then
        return ""
      end
      if match(line, "^%.*\\special%{dvipdfmx:config") then
        return ""
      end
      -- Remove the \special line possibly present in DVI mode for paper size
      if match(line, "^%.*\\special%{papersize") then
        return ""
      end
      -- Remove ConTeXt stuff
      if match(line, "^backend         >") or
         match(line, "^close source    >") or
         match(line, "^mkiv lua stats  >") or
         match(line, "^pages           >") or
         match(line, "^system          >") or
         match(line, "^used file       >") or
         match(line, "^used option     >") or
         match(line, "^used structure  >") then
        return ""
      end
      -- The first time a new font is used by LuaTeX, it shows up
      -- as being cached: make it appear loaded every time
      line = gsub(line, "save cache:", "load cache:")
      -- A tidy-up to keep LuaTeX and other engines in sync
      line = gsub(line, utf8_char(127), "^^?")
      -- Remove lua data reference ids
      line = gsub(line, "<lua data reference [0-9]+>",
                        "<lua data reference ...>")
      -- Unicode engines display chars in the upper half of the 8-bit range:
      -- tidy up to match pdfTeX if an ASCII engine is in use
      if next(asciiengines) then
        for i = 128, 255 do
          line = gsub(line, utf8_char(i), "^^" .. str_format("%02x", i))
        end
      end
      return line, lastline
    end
    local lastline = ""
    local drop_fd = false
    local new_content = ""
    local prestart = true
    local skipping = false
    for line in gmatch(content, "([^\n]*)\n") do
      if line == "START-TEST-LOG" then
        prestart = false
      elseif line == "END-TEST-LOG" or
        match(line, "^Here is how much of .?.?.?TeX\'s memory you used:") then
        break
      elseif line == "OMIT" then
        skipping = true
      elseif match(line, "^%)?TIMO$") then
        skipping = false
      elseif not prestart and not skipping then
        line, lastline, drop_fd = normalize(line, lastline,drop_fd)
        if not match(line, "^ *$") and not killcheck(line) then
          new_content = new_content .. line .. os_newline
        end
      end
    end
    if recordstatus then
      new_content = new_content .. '***************' .. os_newline
      for i = 1, checkruns do
        if (errlevels[i]==nil) then
          new_content = new_content ..
            'Compilation ' .. i .. ' of test file skipped ' .. os_newline
        else
          new_content = new_content ..
            'Compilation ' .. i .. ' of test file completed with exit status ' ..
            errlevels[i] .. os_newline
        end
      end
    end
    return new_content
  end

function rewrite(source,result,processor,...)
    local file = assert(open(source,"rb"))
    local content = gsub(file:read("*all") .. "\n","\r\n","\n")
    close(file)
    local new_content = processor(content,...)
    local newfile = open(result,"w")
    output(newfile)
    write(new_content)
    close(newfile)
  end