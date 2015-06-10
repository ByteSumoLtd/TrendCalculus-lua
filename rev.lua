--[[ 

 _______  ______    _______  __    _  ______     _______  _______  ___      _______  __   __  ___      __   __  _______ 
|       ||    _ |  |       ||  |  | ||      |   |       ||   _   ||   |    |       ||  | |  ||   |    |  | |  ||       |
|_     _||   | ||  |    ___||   |_| ||  _    |  |       ||  |_|  ||   |    |       ||  | |  ||   |    |  | |  ||  _____|
  |   |  |   |_||_ |   |___ |       || | |   |  |       ||       ||   |    |       ||  |_|  ||   |    |  |_|  || |_____ 
  |   |  |    __  ||    ___||  _    || |_|   |  |      _||       ||   |___ |      _||       ||   |___ |       ||_____  |
  |   |  |   |  | ||   |___ | | |   ||       |  |     |_ |   _   ||       ||     |_ |       ||       ||       | _____| |
  |___|  |___|  |_||_______||_|  |__||______|   |_______||__| |__||_______||_______||_______||_______||_______||_______|
                                                                                                                        
Trend Calculus: Reversal and Trend Statistics Generator 

Copyright 2014, 2015, ByteSumo Limited (Andrew J Morgan)

Author: Andrew J Morgan
Notes:  No unauthorised use or distribution of this code what so ever.

License: GPLv3

    This file is part of TrendCalculus.

    TrendCalculus is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    TrendCalculus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with TrendCalculus.  If not, see <http://www.gnu.org/licenses/>.

Revisions::

  2015-04-16
            Created a program that quickly generates reversals from FHLS -s data.
  2015-05-13
            Added in feature to output trend period measures in a genomic format good for circos
  2015-06-07
            Embedded the dependent library code into this program to reduce external dependencies. date, csv, pl.lapp
	    Updated license information. 
  2015-06-10
            Embedded pl.sip as this was needed by pl.lapp. Listed embedded libraries. 

Embedded Libraries::

pl.lapp -- part of the Penlight package for Lua.
	   Copyright (C) 2009 Steve Donovan, David Manura.
	   https://github.com/stevedonovan/Penlight/blob/master/LICENSE.md
           https://github.com/stevedonovan/Penlight  

csv-1.1 -- the csv parsing library for lua.
           Copyright (c) 2013-2014 Incremental IP Limited
           Copyright (c) 2014 Kevin Martin
           https://github.com/geoffleyland/lua-csv/blob/master/LICENSE
           https://github.com/geoffleyland/lua-csv

date	-- Date and Time string parsing; Time addition and subtraction; Time span calculation; Supports ISO 8601 Dates.     
	   Copyright (c) 2013-2014 Thijs Schreijer
           https://github.com/Tieske/date/blob/master/LICENSE   
           http://tieske.github.io/date/ 


--]]

local whohow = [[
---------------------------------------------------------------------------------

             
              |       |     
              |--\  /-|-.-.             .
              |__/\/  | \/_            . :.
               ___/ _   _  _  __   ___/ . .
              / ._|| | | || \/  \ /   \ . : .: 
              \_  \| |_| || | | || [ ] | .. 
              \___/|____/||_|_|_| \___/ ..
                                  / . ..  .:
                                   .: .  .:  
                

  TrendCalculus: Reversal and Trend Statistics Generator
  
  Copyright 2014-2015, ByteSumo Limited (Andrew J Morgan) 

  License: GPLv3
  Author:  Andrew J Morgan
  Version: 1.0.0

  Usage:  
          > cat tst.csv | lua trendcalculus.lua -F "," -h -H -s -n 5 | lua rev.lua -h -H -p 1 -s
          > lua trendcalculus.lua -F "," -h -H -s -n 5 -f tst.csv | lua rev.lua  
  Options
      -v --version                       Show version and help
      -F (string default ",")            input record delimeter
      -OFS (string default ",")          output record delimeter
      -h --header                        indicates there is a column header row
      -H --outheader                     indicate if you want an output header record
      -p --pass                          user value, pass num over the data, with -r option
      -s --stats                         enhanced output with trend statistics
      -g --geneout                       output genomic formatted trend outputs for circos (not available yet)
      <file> (default stdin)             input file to process 

      note: 
        (1)
            on a mac commandline, to set OFS to tab delimited
            you need to use OFS = "ctrl-v<tab>" to get round tab expansion
        (2) 
            Do not set the filename to accept stdin streams   
        (3)
            Data Input Format:
            -- this assumes data is created by FHLS using the options: -s -H  
        (4) 
            This program when it gets column headers on inputs. A column alias feature internally
            helps handle names flexibly. if needed you can edit this source to add new column aliases 
            if needed to simplify your data processing pipeline.
        (5)
            the -s option delivers richer stats about the trends. The extra columns delivers mean the following:
                      "opendate"         -- the trend's open date, preceding the current reversal date found
                      "open"             -- the trend's open value, preceeding the current reversal value found 
                      "diff"             -- the absolute difference in value, from open to close
                      "relrtrn"          -- the relative return of the trend  (close - open) / open
                      "d_days"           -- the difference in days from trend open to close
                      "RatioToPrev"      -- the ratio of this trend's absolute value change, against that of the one before it (of opposite direction)
                      "RatioToPPrev"     -- the ratio of this trend's absolute value change, against that before the previous one 
                                            (compares trends of same direction, included as it is commonly thought to be a fib ratio)
               
        References:
        https://bitbucket.org/bytesumo/trendcalculus-public
        https://github.com/geoffleyland/lua-csv
        https://github.com/stevedonovan/Penlight
        http://tieske.github.io/date/        

---------------------------------------------------------------------------------
     
]]


--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX START OF EMBEDDED LIBRARY CODE. pl.lapp, csv, date. XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


package.preload[ "pl.sip" ] = assert( (loadstring or load)(
"--- Simple Input Patterns (SIP).\
-- SIP patterns start with '$', then a\
-- one-letter type, and then an optional variable in curly braces.\
--\
--    sip.match('$v=$q','name=\"dolly\"',res)\
--    ==> res=={'name','dolly'}\
--    sip.match('($q{first},$q{second})','(\"john\",\"smith\")',res)\
--    ==> res=={second='smith',first='john'}\
--\
-- ''Type names''\
--\
--    v    identifier\
--    i     integer\
--    f     floating-point\
--    q    quoted string\
--    ([{<  match up to closing bracket\
--\
-- See @{08-additional.md.Simple_Input_Patterns|the Guide}\
--\
-- @module pl.sip\
\
local loadstring = rawget(_G,'loadstring') or load\
local unpack = rawget(_G,'unpack') or rawget(table,'unpack')\
\
local append,concat = table.insert,table.concat\
local ipairs,loadstring,type,unpack = ipairs,loadstring,type,unpack\
local io,_G = io,_G\
local print,rawget = print,rawget\
\
local patterns = {\
    FLOAT = '[%+%-%d]%d*%.?%d*[eE]?[%+%-]?%d*',\
    INTEGER = '[+%-%d]%d*',\
    IDEN = '[%a_][%w_]*',\
    FILE = '[%a%.\\\\][:%][%w%._%-\\\\]*',\
    OPTION = '[%a_][%w_%-]*',\
}\
\
local function assert_arg(idx,val,tp)\
    if type(val) ~= tp then\
        error(\"argument \"..idx..\" must be \"..tp, 2)\
    end\
end\
\
\
--[[\
module ('pl.sip',utils._module)\
]]\
\
local sip = {}\
\
local brackets = {['<'] = '>', ['('] = ')', ['{'] = '}', ['['] = ']' }\
local stdclasses = {a=1,c=0,d=1,l=1,p=0,u=1,w=1,x=1,s=0}\
\
local _patterns = {}\
\
\
local function group(s)\
    return '('..s..')'\
end\
\
-- escape all magic characters except $, which has special meaning\
-- Also, un-escape any characters after $, so $( passes through as is.\
local function escape (spec)\
    --_G.print('spec',spec)\
    local res = spec:gsub('[%-%.%+%[%]%(%)%^%%%?%*]','%%%1'):gsub('%$%%(%S)','$%1')\
    --_G.print('res',res)\
    return res\
end\
\
local function imcompressible (s)\
    return s:gsub('%s+','\\001')\
end\
\
-- [handling of spaces in patterns]\
-- spaces may be 'compressed' (i.e will match zero or more spaces)\
-- unless this occurs within a number or an identifier. So we mark\
-- the four possible imcompressible patterns first and then replace.\
-- The possible alnum patterns are v,f,a,d,x,l and u.\
local function compress_spaces (s)\
    s = s:gsub('%$[vifadxlu]%s+%$[vfadxlu]',imcompressible)\
    s = s:gsub('[%w_]%s+[%w_]',imcompressible)\
    s = s:gsub('[%w_]%s+%$[vfadxlu]',imcompressible)\
    s = s:gsub('%$[vfadxlu]%s+[%w_]',imcompressible)\
    s = s:gsub('%s+','%%s*')\
    s = s:gsub('\\001',' ')\
    return s\
end\
\
local pattern_map = {\
  v = group(patterns.IDEN),\
  i = group(patterns.INTEGER),\
  f = group(patterns.FLOAT),\
  o = group(patterns.OPTION),\
  r = '(%S.*)',\
  p = '([%a]?[:]?[\\\\/%.%w_]+)'\
}\
\
function sip.custom_pattern(flag,patt)\
    pattern_map[flag] = patt\
end\
\
--- convert a SIP pattern into the equivalent Lua string pattern.\
-- @param spec a SIP pattern\
-- @param options a table; only the <code>at_start</code> field is\
-- currently meaningful and esures that the pattern is anchored\
-- at the start of the string.\
-- @return a Lua string pattern.\
function sip.create_pattern (spec,options)\
    assert_arg(1,spec,'string')\
    local fieldnames,fieldtypes = {},{}\
\
    if type(spec) == 'string' then\
        spec = escape(spec)\
    else\
        local res = {}\
        for i,s in ipairs(spec) do\
            res[i] = escape(s)\
        end\
        spec = concat(res,'.-')\
    end\
\
    local kount = 1\
\
    local function addfield (name,type)\
        if not name then name = kount end\
        if fieldnames then append(fieldnames,name) end\
        if fieldtypes then fieldtypes[name] = type end\
        kount = kount + 1\
    end\
\
    local named_vars, pattern\
    named_vars = spec:find('{%a+}')\
    pattern = '%$%S'\
\
    if options and options.at_start then\
        spec = '^'..spec\
    end\
    if spec:sub(-1,-1) == '$' then\
        spec = spec:sub(1,-2)..'$r'\
        if named_vars then spec = spec..'{rest}' end\
    end\
\
\
    local names\
\
    if named_vars then\
        names = {}\
        spec = spec:gsub('{(%a+)}',function(name)\
            append(names,name)\
            return ''\
        end)\
    end\
    spec = compress_spaces(spec)\
\
    local k = 1\
    local err\
    local r = (spec:gsub(pattern,function(s)\
        local type,name\
        type = s:sub(2,2)\
        if names then name = names[k]; k=k+1 end\
        -- this kludge is necessary because %q generates two matches, and\
        -- we want to ignore the first. Not a problem for named captures.\
        if not names and type == 'q' then\
            addfield(nil,'Q')\
        else\
            addfield(name,type)\
        end\
        local res\
        if pattern_map[type] then\
            res = pattern_map[type]\
        elseif type == 'q' then\
            -- some Lua pattern matching voodoo; we want to match '...' as\
            -- well as \"...\", and can use the fact that %n will match a\
            -- previous capture. Adding the extra field above comes from needing\
            -- to accomodate the extra spurious match (which is either ' or \")\
            addfield(name,type)\
            res = '([\"\\'])(.-)%'..(kount-2)\
        else\
            local endbracket = brackets[type]\
            if endbracket then\
                res = '(%b'..type..endbracket..')'\
            elseif stdclasses[type] or stdclasses[type:lower()] then\
                res = '(%'..type..'+)'\
            else\
                err = \"unknown format type or character class\"\
            end\
        end\
        return res\
    end))\
    --print(r,err)\
    if err then\
        return nil,err\
    else\
        return r,fieldnames,fieldtypes\
    end\
end\
\
\
local function tnumber (s)\
    return s == 'd' or s == 'i' or s == 'f'\
end\
\
function sip.create_spec_fun(spec,options)\
    local fieldtypes,fieldnames\
    local ls = {}\
    spec,fieldnames,fieldtypes = sip.create_pattern(spec,options)\
    if not spec then return spec,fieldnames end\
    local named_vars = type(fieldnames[1]) == 'string'\
    for i = 1,#fieldnames do\
        append(ls,'mm'..i)\
    end\
    local fun = ('return (function(s,res)\\n\\tlocal %s = s:match(%q)\\n'):format(concat(ls,','),spec)\
    fun = fun..'\\tif not mm1 then return false end\\n'\
    local k=1\
    for i,f in ipairs(fieldnames) do\
        if f ~= '_' then\
            local var = 'mm'..i\
            if tnumber(fieldtypes[f]) then\
                var = 'tonumber('..var..')'\
            elseif brackets[fieldtypes[f]] then\
                var = var..':sub(2,-2)'\
            end\
            if named_vars then\
                fun = ('%s\\tres.%s = %s\\n'):format(fun,f,var)\
            else\
                if fieldtypes[f] ~= 'Q' then -- we skip the string-delim capture\
                    fun = ('%s\\tres[%d] = %s\\n'):format(fun,k,var)\
                    k = k + 1\
                end\
            end\
        end\
    end\
    return fun..'\\treturn true\\nend)\\n', named_vars\
end\
\
--- convert a SIP pattern into a matching function.\
-- The returned function takes two arguments, the line and an empty table.\
-- If the line matched the pattern, then this function return true\
-- and the table is filled with field-value pairs.\
-- @param spec a SIP pattern\
-- @param options optional table; {anywhere=true} will stop pattern anchoring at start\
-- @return a function if successful, or nil,<error>\
function sip.compile(spec,options)\
    assert_arg(1,spec,'string')\
    local fun,names = sip.create_spec_fun(spec,options)\
    if not fun then return nil,names end\
    if rawget(_G,'_DEBUG') then print(fun) end\
    local chunk,err = loadstring(fun,'tmp')\
    if err then return nil,err end\
    return chunk(),names\
end\
\
local cache = {}\
\
--- match a SIP pattern against a string.\
-- @param spec a SIP pattern\
-- @param line a string\
-- @param res a table to receive values\
-- @param options (optional) option table\
-- @return true or false\
function sip.match (spec,line,res,options)\
    assert_arg(1,spec,'string')\
    assert_arg(2,line,'string')\
    assert_arg(3,res,'table')\
    if not cache[spec] then\
        cache[spec] = sip.compile(spec,options)\
    end\
    return cache[spec](line,res)\
end\
\
--- match a SIP pattern against the start of a string.\
-- @param spec a SIP pattern\
-- @param line a string\
-- @param res a table to receive values\
-- @return true or false\
function sip.match_at_start (spec,line,res)\
    return sip.match(spec,line,res,{at_start=true})\
end\
\
--- given a pattern and a file object, return an iterator over the results\
-- @param spec a SIP pattern\
-- @param f a file - use standard input if not specified.\
function sip.fields (spec,f)\
    assert_arg(1,spec,'string')\
    f = f or io.stdin\
    local fun,err = sip.compile(spec)\
    if not fun then return nil,err end\
    local res = {}\
    return function()\
        while true do\
            local line = f:read()\
            if not line then return end\
            if fun(line,res) then\
                local values = res\
                res = {}\
                return unpack(values)\
            end\
        end\
    end\
end\
\
--- register a match which will be used in the read function.\
-- @string spec a SIP pattern\
-- @func fun a function to be called with the results of the match\
-- @see read\
function sip.pattern (spec,fun)\
    assert_arg(1,spec,'string')\
    local pat,named = sip.compile(spec)\
    append(_patterns,{pat=pat,named=named,callback=fun or false})\
end\
\
--- enter a loop which applies all registered matches to the input file.\
-- @param f a file object; if nil, then io.stdin is assumed.\
function sip.read (f)\
    local owned,err\
    f = f or io.stdin\
    if type(f) == 'string' then\
        f,err = io.open(f)\
        if not f then return nil,err end\
        owned = true\
    end\
    local res = {}\
    for line in f:lines() do\
        for _,item in ipairs(_patterns) do\
            if item.pat(line,res) then\
                if item.callback then\
                    if item.named then\
                        item.callback(res)\
                    else\
                        item.callback(unpack(res))\
                    end\
                end\
                res = {}\
                break\
            end\
        end\
    end\
    if owned then f:close() end\
end\
\
return sip\
"
, '@'.."/Users/andrewmorgan/torch/install/share/lua/5.1/pl/sip.lua" ) )






package.preload[ "date" ] = assert( (loadstring or load)(
"---------------------------------------------------------------------------------------\
-- Module for date and time calculations\
--\
-- Version 2.1.1\
-- Copyright (C) 2006, by Jas Latrix (jastejada@yahoo.com)\
-- Copyright (C) 2013-2014, by Thijs Schreijer\
-- Licensed under MIT, http://opensource.org/licenses/MIT\
\
--[[ CONSTANTS ]]--\
  local HOURPERDAY  = 24\
  local MINPERHOUR  = 60\
  local MINPERDAY    = 1440  -- 24*60\
  local SECPERMIN   = 60\
  local SECPERHOUR  = 3600  -- 60*60\
  local SECPERDAY   = 86400 -- 24*60*60\
  local TICKSPERSEC = 1000000\
  local TICKSPERDAY = 86400000000\
  local TICKSPERHOUR = 3600000000\
  local TICKSPERMIN = 60000000\
  local DAYNUM_MAX =  365242500 -- Sat Jan 01 1000000 00:00:00\
  local DAYNUM_MIN = -365242500 -- Mon Jan 01 1000000 BCE 00:00:00\
  local DAYNUM_DEF =  0 -- Mon Jan 01 0001 00:00:00\
  local _;\
--[[ LOCAL ARE FASTER ]]--\
  local type     = type\
  local pairs    = pairs\
  local error    = error\
  local assert   = assert\
  local tonumber = tonumber\
  local tostring = tostring\
  local string   = string\
  local math     = math\
  local os       = os\
  local unpack   = unpack or table.unpack\
  local pack     = table.pack or function(...) return { n = select('#', ...), ... } end\
  local setmetatable = setmetatable\
  local getmetatable = getmetatable\
--[[ EXTRA FUNCTIONS ]]--\
  local fmt  = string.format\
  local lwr  = string.lower\
  local upr  = string.upper\
  local rep  = string.rep\
  local len  = string.len\
  local sub  = string.sub\
  local gsub = string.gsub\
  local gmatch = string.gmatch or string.gfind\
  local find = string.find\
  local ostime = os.time\
  local osdate = os.date\
  local floor = math.floor\
  local ceil  = math.ceil\
  local abs   = math.abs\
  -- removes the decimal part of a number\
  local function fix(n) n = tonumber(n) return n and ((n > 0 and floor or ceil)(n)) end\
  -- returns the modulo n % d;\
  local function mod(n,d) return n - d*floor(n/d) end\
  -- rounds a number;\
  local function round(n, d) d=d^10 return floor((n*d)+.5)/d end\
  -- rounds a number to whole;\
  local function whole(n)return floor(n+.5)end\
  -- is `str` in string list `tbl`, `ml` is the minimun len\
  local function inlist(str, tbl, ml, tn)\
    local sl = len(str)\
    if sl < (ml or 0) then return nil end\
    str = lwr(str)\
    for k, v in pairs(tbl) do\
      if str == lwr(sub(v, 1, sl)) then\
        if tn then tn[0] = k end\
        return k\
      end\
    end\
  end\
  local function fnil() end\
  local function fret(x)return x;end\
--[[ DATE FUNCTIONS ]]--\
  local DATE_EPOCH -- to be set later\
  local sl_weekdays = {\
    [0]=\"Sunday\",[1]=\"Monday\",[2]=\"Tuesday\",[3]=\"Wednesday\",[4]=\"Thursday\",[5]=\"Friday\",[6]=\"Saturday\",\
    [7]=\"Sun\",[8]=\"Mon\",[9]=\"Tue\",[10]=\"Wed\",[11]=\"Thu\",[12]=\"Fri\",[13]=\"Sat\",\
  }\
  local sl_meridian = {[-1]=\"AM\", [1]=\"PM\"}\
  local sl_months = {\
    [00]=\"January\", [01]=\"February\", [02]=\"March\",\
    [03]=\"April\",   [04]=\"May\",      [05]=\"June\",\
    [06]=\"July\",    [07]=\"August\",   [08]=\"September\",\
    [09]=\"October\", [10]=\"November\", [11]=\"December\",\
    [12]=\"Jan\", [13]=\"Feb\", [14]=\"Mar\",\
    [15]=\"Apr\", [16]=\"May\", [17]=\"Jun\",\
    [18]=\"Jul\", [19]=\"Aug\", [20]=\"Sep\",\
    [21]=\"Oct\", [22]=\"Nov\", [23]=\"Dec\",\
  }\
  -- added the '.2'  to avoid collision, use `fix` to remove\
  local sl_timezone = {\
    [000]=\"utc\",    [0.2]=\"gmt\",\
    [300]=\"est\",    [240]=\"edt\",\
    [360]=\"cst\",  [300.2]=\"cdt\",\
    [420]=\"mst\",  [360.2]=\"mdt\",\
    [480]=\"pst\",  [420.2]=\"pdt\",\
  }\
  -- set the day fraction resolution\
  local function setticks(t)\
    TICKSPERSEC = t;\
    TICKSPERDAY = SECPERDAY*TICKSPERSEC\
    TICKSPERHOUR= SECPERHOUR*TICKSPERSEC\
    TICKSPERMIN = SECPERMIN*TICKSPERSEC\
  end\
  -- is year y leap year?\
  local function isleapyear(y) -- y must be int!\
    return (mod(y, 4) == 0 and (mod(y, 100) ~= 0 or mod(y, 400) == 0))\
  end\
  -- day since year 0\
  local function dayfromyear(y) -- y must be int!\
    return 365*y + floor(y/4) - floor(y/100) + floor(y/400)\
  end\
  -- day number from date, month is zero base\
  local function makedaynum(y, m, d)\
    local mm = mod(mod(m,12) + 10, 12)\
    return dayfromyear(y + floor(m/12) - floor(mm/10)) + floor((mm*306 + 5)/10) + d - 307\
    --local yy = y + floor(m/12) - floor(mm/10)\
    --return dayfromyear(yy) + floor((mm*306 + 5)/10) + (d - 1)\
  end\
  -- date from day number, month is zero base\
  local function breakdaynum(g)\
    local g = g + 306\
    local y = floor((10000*g + 14780)/3652425)\
    local d = g - dayfromyear(y)\
    if d < 0 then y = y - 1; d = g - dayfromyear(y) end\
    local mi = floor((100*d + 52)/3060)\
    return (floor((mi + 2)/12) + y), mod(mi + 2,12), (d - floor((mi*306 + 5)/10) + 1)\
  end\
  --[[ for floats or int32 Lua Number data type\
  local function breakdaynum2(g)\
    local g, n = g + 306;\
    local n400 = floor(g/DI400Y);n = mod(g,DI400Y);\
    local n100 = floor(n/DI100Y);n = mod(n,DI100Y);\
    local n004 = floor(n/DI4Y);   n = mod(n,DI4Y);\
    local n001 = floor(n/365);   n = mod(n,365);\
    local y = (n400*400) + (n100*100) + (n004*4) + n001  - ((n001 == 4 or n100 == 4) and 1 or 0)\
    local d = g - dayfromyear(y)\
    local mi = floor((100*d + 52)/3060)\
    return (floor((mi + 2)/12) + y), mod(mi + 2,12), (d - floor((mi*306 + 5)/10) + 1)    \
  end\
  ]]    \
  -- day fraction from time\
  local function makedayfrc(h,r,s,t)\
    return ((h*60 + r)*60 + s)*TICKSPERSEC + t\
  end\
  -- time from day fraction\
  local function breakdayfrc(df)\
    return\
      mod(floor(df/TICKSPERHOUR),HOURPERDAY),\
      mod(floor(df/TICKSPERMIN ),MINPERHOUR),\
      mod(floor(df/TICKSPERSEC ),SECPERMIN),\
      mod(df,TICKSPERSEC)\
  end\
  -- weekday sunday = 0, monday = 1 ...\
  local function weekday(dn) return mod(dn + 1, 7) end\
  -- yearday 0 based ...\
  local function yearday(dn)\
     return dn - dayfromyear((breakdaynum(dn))-1)\
  end\
  -- parse v as a month\
  local function getmontharg(v)\
    local m = tonumber(v);\
    return (m and fix(m - 1)) or inlist(tostring(v) or \"\", sl_months, 2)\
  end\
  -- get daynum of isoweek one of year y\
  local function isow1(y)\
    local f = makedaynum(y, 0, 4) -- get the date for the 4-Jan of year `y`\
    local d = weekday(f)\
    d = d == 0 and 7 or d -- get the ISO day number, 1 == Monday, 7 == Sunday\
    return f + (1 - d)\
  end\
  local function isowy(dn)\
    local w1;\
    local y = (breakdaynum(dn))\
    if dn >= makedaynum(y, 11, 29) then\
      w1 = isow1(y + 1);\
      if dn < w1 then\
        w1 = isow1(y);\
      else\
          y = y + 1;\
      end\
    else\
      w1 = isow1(y);\
      if dn < w1 then\
        w1 = isow1(y-1)\
        y = y - 1\
      end\
    end\
    return floor((dn-w1)/7)+1, y\
  end\
  local function isoy(dn)\
    local y = (breakdaynum(dn))\
    return y + (((dn >= makedaynum(y, 11, 29)) and (dn >= isow1(y + 1))) and 1 or (dn < isow1(y) and -1 or 0))\
  end\
  local function makedaynum_isoywd(y,w,d)\
    return isow1(y) + 7*w + d - 8 -- simplified: isow1(y) + ((w-1)*7) + (d-1)\
  end\
--[[ THE DATE MODULE ]]--\
  local fmtstr  = \"%x %X\";\
--#if not DATE_OBJECT_AFX then\
  local date = {}\
  setmetatable(date, date)\
-- Version:  VMMMRRRR; V-Major, M-Minor, R-Revision;  e.g. 5.45.321 == 50450321\
  date.version = 20010001 -- 2.1.1\
--#end -- not DATE_OBJECT_AFX\
--[[ THE DATE OBJECT ]]--\
  local dobj = {}\
  dobj.__index = dobj\
  dobj.__metatable = dobj\
  -- shout invalid arg\
  local function date_error_arg() return error(\"invalid argument(s)\",0) end\
  -- create new date object\
  local function date_new(dn, df)\
    return setmetatable({daynum=dn, dayfrc=df}, dobj)\
  end\
  -- is `v` a date object?\
  local function date_isdobj(v)\
    return (type(v) == 'table' and getmetatable(v) == dobj) and v\
  end\
\
--#if not NO_LOCAL_TIME_SUPPORT then\
  -- magic year table\
  local date_epoch, yt;\
  local function getequivyear(y)\
    assert(not yt)\
    yt = {}\
    local de, dw, dy = date_epoch:copy()\
    for i = 0, 3000 do\
      de:setyear(de:getyear() + 1, 1, 1)\
      dy = de:getyear()\
      dw = de:getweekday() * (isleapyear(dy) and  -1 or 1)\
      if not yt[dw] then yt[dw] = dy end  --print(de)\
      if yt[1] and yt[2] and yt[3] and yt[4] and yt[5] and yt[6] and yt[7] and yt[-1] and yt[-2] and yt[-3] and yt[-4] and yt[-5] and yt[-6] and yt[-7] then\
        getequivyear = function(y)  return yt[ (weekday(makedaynum(y, 0, 1)) + 1) * (isleapyear(y) and  -1 or 1) ]  end\
        return getequivyear(y)\
      end\
    end\
  end\
  -- TimeValue from daynum and dayfrc\
  local function dvtotv(dn, df)\
    return fix(dn - DATE_EPOCH) * SECPERDAY  + (df/1000)\
  end\
  -- TimeValue from date and time\
  local function totv(y,m,d,h,r,s)\
    return (makedaynum(y, m, d) - DATE_EPOCH) * SECPERDAY  + ((h*60 + r)*60 + s)\
  end\
  -- TimeValue from TimeTable\
  local function tmtotv(tm)\
    return tm and totv(tm.year, tm.month - 1, tm.day, tm.hour, tm.min, tm.sec)\
  end\
  -- Returns the bias in seconds of utc time daynum and dayfrc\
  local function getbiasutc2(self)\
    local y,m,d = breakdaynum(self.daynum)\
    local h,r,s = breakdayfrc(self.dayfrc)\
    local tvu = totv(y,m,d,h,r,s) -- get the utc TimeValue of date and time\
    local tml = osdate(\"*t\", tvu) -- get the local TimeTable of tvu\
    if (not tml) or (tml.year > (y+1) or tml.year < (y-1)) then -- failed try the magic\
      y = getequivyear(y)\
      tvu = totv(y,m,d,h,r,s)\
      tml = osdate(\"*t\", tvu)\
    end\
    local tvl = tmtotv(tml)\
    if tvu and tvl then\
      return tvu - tvl, tvu, tvl\
    else\
      return error(\"failed to get bias from utc time\")\
    end\
  end\
  -- Returns the bias in seconds of local time daynum and dayfrc\
  local function getbiasloc2(daynum, dayfrc)\
    local tvu\
    -- extract date and time\
    local y,m,d = breakdaynum(daynum)\
    local h,r,s = breakdayfrc(dayfrc)\
    -- get equivalent TimeTable\
    local tml = {year=y, month=m+1, day=d, hour=h, min=r, sec=s}\
    -- get equivalent TimeValue\
    local tvl = tmtotv(tml)\
\
    local function chkutc()\
      tml.isdst =  nil; local tvug = ostime(tml) if tvug and (tvl == tmtotv(osdate(\"*t\", tvug))) then tvu = tvug return end\
      tml.isdst = true; local tvud = ostime(tml) if tvud and (tvl == tmtotv(osdate(\"*t\", tvud))) then tvu = tvud return end\
      tvu = tvud or tvug\
    end\
    chkutc()\
    if not tvu then\
      tml.year = getequivyear(y)\
      tvl = tmtotv(tml)\
      chkutc()\
    end\
    return ((tvu and tvl) and (tvu - tvl)) or error(\"failed to get bias from local time\"), tvu, tvl\
  end\
--#end -- not NO_LOCAL_TIME_SUPPORT\
\
--#if not DATE_OBJECT_AFX then\
  -- the date parser\
  local strwalker = {} -- ^Lua regular expression is not as powerful as Perl$\
  strwalker.__index = strwalker\
  local function newstrwalker(s)return setmetatable({s=s, i=1, e=1, c=len(s)}, strwalker) end\
  function strwalker:aimchr() return \"\\n\" .. self.s .. \"\\n\" .. rep(\".\",self.e-1) .. \"^\" end\
  function strwalker:finish() return self.i > self.c  end\
  function strwalker:back()  self.i = self.e return self  end\
  function strwalker:restart() self.i, self.e = 1, 1 return self end\
  function strwalker:match(s)  return (find(self.s, s, self.i)) end\
  function strwalker:__call(s, f)-- print(\"strwalker:__call \"..s..self:aimchr())\
    local is, ie; is, ie, self[1], self[2], self[3], self[4], self[5] = find(self.s, s, self.i)\
    if is then self.e, self.i = self.i, 1+ie; if f then f(unpack(self)) end return self end\
  end\
   local function date_parse(str)\
    local y,m,d, h,r,s,  z,  w,u, j,  e,  k,  x,v,c,  chkfin,  dn,df;\
    local sw = newstrwalker(gsub(gsub(str, \"(%b())\", \"\"),\"^(%s*)\",\"\")) -- remove comment, trim leading space\
    --local function error_out() print(y,m,d,h,r,s) end\
    local function error_dup(q) --[[error_out()]] error(\"duplicate value: \" .. (q or \"\") .. sw:aimchr()) end\
    local function error_syn(q) --[[error_out()]] error(\"syntax error: \" .. (q or \"\") .. sw:aimchr()) end\
    local function error_inv(q) --[[error_out()]] error(\"invalid date: \" .. (q or \"\") .. sw:aimchr()) end\
    local function sety(q) y = y and error_dup() or tonumber(q); end\
    local function setm(q) m = (m or w or j) and error_dup(m or w or j) or tonumber(q) end\
    local function setd(q) d = d and error_dup() or tonumber(q) end\
    local function seth(q) h = h and error_dup() or tonumber(q) end\
    local function setr(q) r = r and error_dup() or tonumber(q) end\
    local function sets(q) s = s and error_dup() or tonumber(q) end\
    local function adds(q) s = s + tonumber(q) end\
    local function setj(q) j = (m or w or j) and error_dup() or tonumber(q); end\
    local function setz(q) z = (z ~= 0 and z) and error_dup() or q end\
    local function setzn(zs,zn) zn = tonumber(zn); setz( ((zn<24) and (zn*60) or (mod(zn,100) + floor(zn/100) * 60))*( zs=='+' and -1 or 1) ) end\
    local function setzc(zs,zh,zm) setz( ((tonumber(zh)*60) + tonumber(zm))*( zs=='+' and -1 or 1) ) end\
\
    if not (sw(\"^(%d%d%d%d)\",sety) and (sw(\"^(%-?)(%d%d)%1(%d%d)\",function(_,a,b) setm(tonumber(a)); setd(tonumber(b)) end) or sw(\"^(%-?)[Ww](%d%d)%1(%d?)\",function(_,a,b) w, u = tonumber(a), tonumber(b or 1) end) or sw(\"^%-?(%d%d%d)\",setj) or sw(\"^%-?(%d%d)\",function(a) setm(a);setd(1) end))\
    and ((sw(\"^%s*[Tt]?(%d%d):?\",seth) and sw(\"^(%d%d):?\",setr) and sw(\"^(%d%d)\",sets) and sw(\"^(%.%d+)\",adds))\
      or sw:finish() or (sw\"^%s*$\" or sw\"^%s*[Zz]%s*$\" or sw(\"^%s-([%+%-])(%d%d):?(%d%d)%s*$\",setzc) or sw(\"^%s*([%+%-])(%d%d)%s*$\",setzn))\
      )  )\
    then --print(y,m,d,h,r,s,z,w,u,j)\
    sw:restart(); y,m,d,h,r,s,z,w,u,j = nil;\
      repeat -- print(sw:aimchr())\
        if sw(\"^[tT:]?%s*(%d%d?):\",seth) then --print(\"$Time\")\
          _ = sw(\"^%s*(%d%d?)\",setr) and sw(\"^%s*:%s*(%d%d?)\",sets) and sw(\"^(%.%d+)\",adds)\
        elseif sw(\"^(%d+)[/\\\\%s,-]?%s*\") then --print(\"$Digits\")\
          x, c = tonumber(sw[1]), len(sw[1])\
          if (x >= 70) or (m and d and (not y)) or (c > 3) then\
            sety( x + ((x >= 100 or c>3)and 0 or 1900) )\
          else\
            if m then setd(x) else m = x end\
          end\
        elseif sw(\"^(%a+)[/\\\\%s,-]?%s*\") then --print(\"$Words\")\
          x = sw[1]\
          if inlist(x, sl_months,   2, sw) then\
            if m and (not d) and (not y) then d, m = m, false end\
            setm(mod(sw[0],12)+1)\
          elseif inlist(x, sl_timezone, 2, sw) then\
            c = fix(sw[0]) -- ignore gmt and utc\
            if c ~= 0 then setz(c, x) end\
          elseif inlist(x, sl_weekdays, 2, sw) then\
            k = sw[0]\
          else\
            sw:back()\
            -- am pm bce ad ce bc\
            if sw(\"^([bB])%s*(%.?)%s*[Cc]%s*(%2)%s*[Ee]%s*(%2)%s*\") or sw(\"^([bB])%s*(%.?)%s*[Cc]%s*(%2)%s*\") then\
              e = e and error_dup() or -1\
            elseif sw(\"^([aA])%s*(%.?)%s*[Dd]%s*(%2)%s*\") or sw(\"^([cC])%s*(%.?)%s*[Ee]%s*(%2)%s*\") then\
              e = e and error_dup() or 1\
            elseif sw(\"^([PApa])%s*(%.?)%s*[Mm]?%s*(%2)%s*\") then\
              x = lwr(sw[1]) -- there should be hour and it must be correct\
              if (not h) or (h > 12) or (h < 0) then return error_inv() end\
              if x == 'a' and h == 12 then h = 0 end -- am\
              if x == 'p' and h ~= 12 then h = h + 12 end -- pm\
            else error_syn() end\
          end\
        elseif not(sw(\"^([+-])(%d%d?):(%d%d)\",setzc) or sw(\"^([+-])(%d+)\",setzn) or sw(\"^[Zz]%s*$\")) then -- sw{\"([+-])\",{\"(%d%d?):(%d%d)\",\"(%d+)\"}}\
          error_syn(\"?\")\
        end\
      sw(\"^%s*\")  until sw:finish()\
    --else print(\"$Iso(Date|Time|Zone)\")\
    end\
    -- if date is given, it must be complete year, month & day\
    if (not y and not h) or ((m and not d) or (d and not m)) or ((m and w) or (m and j) or (j and w)) then return error_inv(\"!\") end\
    -- fix month\
    if m then m = m - 1 end\
    -- fix year if we are on BCE\
    if e and e < 0 and y > 0 then y = 1 - y end\
    --  create date object\
    dn = (y and ((w and makedaynum_isoywd(y,w,u)) or (j and makedaynum(y, 0, j)) or makedaynum(y, m, d))) or DAYNUM_DEF\
    df = makedayfrc(h or 0, r or 0, s or 0, 0) + ((z or 0)*TICKSPERMIN)\
    --print(\"Zone\",h,r,s,z,m,d,y,df)\
    return date_new(dn, df) -- no need to :normalize();\
   end\
  local function date_fromtable(v)\
    local y, m, d = fix(v.year), getmontharg(v.month), fix(v.day)\
    local h, r, s, t = tonumber(v.hour), tonumber(v.min), tonumber(v.sec), tonumber(v.ticks)\
    -- atleast there is time or complete date\
    if (y or m or d) and (not(y and m and d)) then return error(\"incomplete table\")  end\
    return (y or h or r or s or t) and date_new(y and makedaynum(y, m, d) or DAYNUM_DEF, makedayfrc(h or 0, r or 0, s or 0, t or 0))\
  end\
  local tmap = {\
    ['number'] = function(v) return date_epoch:copy():addseconds(v) end,\
    ['string'] = function(v) return date_parse(v) end,\
    ['boolean']= function(v) return date_fromtable(osdate(v and \"!*t\" or \"*t\")) end,\
    ['table']  = function(v) local ref = getmetatable(v) == dobj; return ref and v or date_fromtable(v), ref end\
  }\
  local function date_getdobj(v)\
    local o, r = (tmap[type(v)] or fnil)(v);\
    return (o and o:normalize() or error\"invalid date time value\"), r -- if r is true then o is a reference to a date obj\
  end\
--#end -- not DATE_OBJECT_AFX\
  local function date_from(...)\
    local arg = pack(...)\
    local y, m, d = fix(arg[1]), getmontharg(arg[2]), fix(arg[3])\
    local h, r, s, t = tonumber(arg[4] or 0), tonumber(arg[5] or 0), tonumber(arg[6] or 0), tonumber(arg[7] or 0)\
    if y and m and d and h and r and s and t then\
      return date_new(makedaynum(y, m, d), makedayfrc(h, r, s, t)):normalize()\
    else\
      return date_error_arg()\
    end\
  end\
\
 --[[ THE DATE OBJECT METHODS ]]--\
  function dobj:normalize()\
    local dn, df = fix(self.daynum), self.dayfrc\
    self.daynum, self.dayfrc = dn + floor(df/TICKSPERDAY), mod(df, TICKSPERDAY)\
    return (dn >= DAYNUM_MIN and dn <= DAYNUM_MAX) and self or error(\"date beyond imposed limits:\"..self)\
  end\
\
  function dobj:getdate()  local y, m, d = breakdaynum(self.daynum) return y, m+1, d end\
  function dobj:gettime()  return breakdayfrc(self.dayfrc) end\
\
  function dobj:getclockhour() local h = self:gethours() return h>12 and mod(h,12) or (h==0 and 12 or h) end\
\
  function dobj:getyearday() return yearday(self.daynum) + 1 end\
  function dobj:getweekday() return weekday(self.daynum) + 1 end   -- in lua weekday is sunday = 1, monday = 2 ...\
\
  function dobj:getyear()   local r,_,_ = breakdaynum(self.daynum)  return r end\
  function dobj:getmonth() local _,r,_ = breakdaynum(self.daynum)  return r+1 end-- in lua month is 1 base\
  function dobj:getday()   local _,_,r = breakdaynum(self.daynum)  return r end\
  function dobj:gethours()  return mod(floor(self.dayfrc/TICKSPERHOUR),HOURPERDAY) end\
  function dobj:getminutes()  return mod(floor(self.dayfrc/TICKSPERMIN), MINPERHOUR) end\
  function dobj:getseconds()  return mod(floor(self.dayfrc/TICKSPERSEC ),SECPERMIN)  end\
  function dobj:getfracsec()  return mod(floor(self.dayfrc/TICKSPERSEC ),SECPERMIN)+(mod(self.dayfrc,TICKSPERSEC)/TICKSPERSEC) end\
  function dobj:getticks(u)  local x = mod(self.dayfrc,TICKSPERSEC) return u and ((x*u)/TICKSPERSEC) or x  end\
\
  function dobj:getweeknumber(wdb)\
    local wd, yd = weekday(self.daynum), yearday(self.daynum)\
    if wdb then\
      wdb = tonumber(wdb)\
      if wdb then\
        wd = mod(wd-(wdb-1),7)-- shift the week day base\
      else\
        return date_error_arg()\
      end\
    end\
    return (yd < wd and 0) or (floor(yd/7) + ((mod(yd, 7)>=wd) and 1 or 0))\
  end\
\
  function dobj:getisoweekday() return mod(weekday(self.daynum)-1,7)+1 end   -- sunday = 7, monday = 1 ...\
  function dobj:getisoweeknumber() return (isowy(self.daynum)) end\
  function dobj:getisoyear() return isoy(self.daynum)  end\
  function dobj:getisodate()\
    local w, y = isowy(self.daynum)\
    return y, w, self:getisoweekday()\
  end\
  function dobj:setisoyear(y, w, d)\
    local cy, cw, cd = self:getisodate()\
    if y then cy = fix(tonumber(y))end\
    if w then cw = fix(tonumber(w))end\
    if d then cd = fix(tonumber(d))end\
    if cy and cw and cd then\
      self.daynum = makedaynum_isoywd(cy, cw, cd)\
      return self:normalize()\
    else\
      return date_error_arg()\
    end\
  end\
\
  function dobj:setisoweekday(d)    return self:setisoyear(nil, nil, d) end\
  function dobj:setisoweeknumber(w,d)  return self:setisoyear(nil, w, d)  end\
\
  function dobj:setyear(y, m, d)\
    local cy, cm, cd = breakdaynum(self.daynum)\
    if y then cy = fix(tonumber(y))end\
    if m then cm = getmontharg(m)  end\
    if d then cd = fix(tonumber(d))end\
    if cy and cm and cd then\
      self.daynum  = makedaynum(cy, cm, cd)\
      return self:normalize()\
    else\
      return date_error_arg()\
    end\
  end\
\
  function dobj:setmonth(m, d)return self:setyear(nil, m, d) end\
  function dobj:setday(d)    return self:setyear(nil, nil, d) end\
\
  function dobj:sethours(h, m, s, t)\
    local ch,cm,cs,ck = breakdayfrc(self.dayfrc)\
    ch, cm, cs, ck = tonumber(h or ch), tonumber(m or cm), tonumber(s or cs), tonumber(t or ck)\
    if ch and cm and cs and ck then\
      self.dayfrc = makedayfrc(ch, cm, cs, ck)\
      return self:normalize()\
    else\
      return date_error_arg()\
    end\
  end\
\
  function dobj:setminutes(m,s,t)  return self:sethours(nil,   m,   s, t) end\
  function dobj:setseconds(s, t)  return self:sethours(nil, nil,   s, t) end\
  function dobj:setticks(t)    return self:sethours(nil, nil, nil, t) end\
\
  function dobj:spanticks()  return (self.daynum*TICKSPERDAY + self.dayfrc) end\
  function dobj:spanseconds()  return (self.daynum*TICKSPERDAY + self.dayfrc)/TICKSPERSEC  end\
  function dobj:spanminutes()  return (self.daynum*TICKSPERDAY + self.dayfrc)/TICKSPERMIN  end\
  function dobj:spanhours()  return (self.daynum*TICKSPERDAY + self.dayfrc)/TICKSPERHOUR end\
  function dobj:spandays()  return (self.daynum*TICKSPERDAY + self.dayfrc)/TICKSPERDAY  end\
\
  function dobj:addyears(y, m, d)\
    local cy, cm, cd = breakdaynum(self.daynum)\
    if y then y = fix(tonumber(y))else y = 0 end\
    if m then m = fix(tonumber(m))else m = 0 end\
    if d then d = fix(tonumber(d))else d = 0 end\
    if y and m and d then\
      self.daynum  = makedaynum(cy+y, cm+m, cd+d)\
      return self:normalize()\
    else\
      return date_error_arg()\
    end\
  end\
\
  function dobj:addmonths(m, d)\
    return self:addyears(nil, m, d)\
  end\
\
  local function dobj_adddayfrc(self,n,pt,pd)\
    n = tonumber(n)\
    if n then\
      local x = floor(n/pd);\
      self.daynum = self.daynum + x;\
      self.dayfrc = self.dayfrc + (n-x*pd)*pt;\
      return self:normalize()\
    else\
      return date_error_arg()\
    end\
  end\
  function dobj:adddays(n)  return dobj_adddayfrc(self,n,TICKSPERDAY,1) end\
  function dobj:addhours(n)  return dobj_adddayfrc(self,n,TICKSPERHOUR,HOURPERDAY) end\
  function dobj:addminutes(n)  return dobj_adddayfrc(self,n,TICKSPERMIN,MINPERDAY)  end\
  function dobj:addseconds(n)  return dobj_adddayfrc(self,n,TICKSPERSEC,SECPERDAY)  end\
  function dobj:addticks(n)  return dobj_adddayfrc(self,n,1,TICKSPERDAY) end\
  local tvspec = {\
    -- Abbreviated weekday name (Sun)\
    ['%a']=function(self) return sl_weekdays[weekday(self.daynum) + 7] end,\
    -- Full weekday name (Sunday)\
    ['%A']=function(self) return sl_weekdays[weekday(self.daynum)] end,\
    -- Abbreviated month name (Dec)\
    ['%b']=function(self) return sl_months[self:getmonth() - 1 + 12] end,\
    -- Full month name (December)\
    ['%B']=function(self) return sl_months[self:getmonth() - 1] end,\
    -- Year/100 (19, 20, 30)\
    ['%C']=function(self) return fmt(\"%.2d\", fix(self:getyear()/100)) end,\
    -- The day of the month as a number (range 1 - 31)\
    ['%d']=function(self) return fmt(\"%.2d\", self:getday())  end,\
    -- year for ISO 8601 week, from 00 (79)\
    ['%g']=function(self) return fmt(\"%.2d\", mod(self:getisoyear() ,100)) end,\
    -- year for ISO 8601 week, from 0000 (1979)\
    ['%G']=function(self) return fmt(\"%.4d\", self:getisoyear()) end,\
    -- same as %b\
    ['%h']=function(self) return self:fmt0(\"%b\") end,\
    -- hour of the 24-hour day, from 00 (06)\
    ['%H']=function(self) return fmt(\"%.2d\", self:gethours()) end,\
    -- The  hour as a number using a 12-hour clock (01 - 12)\
    ['%I']=function(self) return fmt(\"%.2d\", self:getclockhour()) end,\
    -- The day of the year as a number (001 - 366)\
    ['%j']=function(self) return fmt(\"%.3d\", self:getyearday())  end,\
    -- Month of the year, from 01 to 12\
    ['%m']=function(self) return fmt(\"%.2d\", self:getmonth())  end,\
    -- Minutes after the hour 55\
    ['%M']=function(self) return fmt(\"%.2d\", self:getminutes())end,\
    -- AM/PM indicator (AM)\
    ['%p']=function(self) return sl_meridian[self:gethours() > 11 and 1 or -1] end, --AM/PM indicator (AM)\
    -- The second as a number (59, 20 , 01)\
    ['%S']=function(self) return fmt(\"%.2d\", self:getseconds())  end,\
    -- ISO 8601 day of the week, to 7 for Sunday (7, 1)\
    ['%u']=function(self) return self:getisoweekday() end,\
    -- Sunday week of the year, from 00 (48)\
    ['%U']=function(self) return fmt(\"%.2d\", self:getweeknumber()) end,\
    -- ISO 8601 week of the year, from 01 (48)\
    ['%V']=function(self) return fmt(\"%.2d\", self:getisoweeknumber()) end,\
    -- The day of the week as a decimal, Sunday being 0\
    ['%w']=function(self) return self:getweekday() - 1 end,\
    -- Monday week of the year, from 00 (48)\
    ['%W']=function(self) return fmt(\"%.2d\", self:getweeknumber(2)) end,\
    -- The year as a number without a century (range 00 to 99)\
    ['%y']=function(self) return fmt(\"%.2d\", mod(self:getyear() ,100)) end,\
    -- Year with century (2000, 1914, 0325, 0001)\
    ['%Y']=function(self) return fmt(\"%.4d\", self:getyear()) end,\
    -- Time zone offset, the date object is assumed local time (+1000, -0230)\
    ['%z']=function(self) local b = -self:getbias(); local x = abs(b); return fmt(\"%s%.4d\", b < 0 and \"-\" or \"+\", fix(x/60)*100 + floor(mod(x,60))) end,\
    -- Time zone name, the date object is assumed local time\
    ['%Z']=function(self) return self:gettzname() end,\
    -- Misc --\
    -- Year, if year is in BCE, prints the BCE Year representation, otherwise result is similar to \"%Y\" (1 BCE, 40 BCE)\
    ['%\\b']=function(self) local x = self:getyear() return fmt(\"%.4d%s\", x>0 and x or (-x+1), x>0 and \"\" or \" BCE\") end,\
    -- Seconds including fraction (59.998, 01.123)\
    ['%\\f']=function(self) local x = self:getfracsec() return fmt(\"%s%.9g\",x >= 10 and \"\" or \"0\", x) end,\
    -- percent character %\
    ['%%']=function(self) return \"%\" end,\
    -- Group Spec --\
    -- 12-hour time, from 01:00:00 AM (06:55:15 AM); same as \"%I:%M:%S %p\"\
    ['%r']=function(self) return self:fmt0(\"%I:%M:%S %p\") end,\
    -- hour:minute, from 01:00 (06:55); same as \"%I:%M\"\
    ['%R']=function(self) return self:fmt0(\"%I:%M\")  end,\
    -- 24-hour time, from 00:00:00 (06:55:15); same as \"%H:%M:%S\"\
    ['%T']=function(self) return self:fmt0(\"%H:%M:%S\") end,\
    -- month/day/year from 01/01/00 (12/02/79); same as \"%m/%d/%y\"\
    ['%D']=function(self) return self:fmt0(\"%m/%d/%y\") end,\
    -- year-month-day (1979-12-02); same as \"%Y-%m-%d\"\
    ['%F']=function(self) return self:fmt0(\"%Y-%m-%d\") end,\
    -- The preferred date and time representation;  same as \"%x %X\"\
    ['%c']=function(self) return self:fmt0(\"%x %X\") end,\
    -- The preferred date representation, same as \"%a %b %d %\\b\"\
    ['%x']=function(self) return self:fmt0(\"%a %b %d %\\b\") end,\
    -- The preferred time representation, same as \"%H:%M:%\\f\"\
    ['%X']=function(self) return self:fmt0(\"%H:%M:%\\f\") end,\
    -- GroupSpec --\
    -- Iso format, same as \"%Y-%m-%dT%T\"\
    ['${iso}'] = function(self) return self:fmt0(\"%Y-%m-%dT%T\") end,\
    -- http format, same as \"%a, %d %b %Y %T GMT\"\
    ['${http}'] = function(self) return self:fmt0(\"%a, %d %b %Y %T GMT\") end,\
    -- ctime format, same as \"%a %b %d %T GMT %Y\"\
    ['${ctime}'] = function(self) return self:fmt0(\"%a %b %d %T GMT %Y\") end,\
    -- RFC850 format, same as \"%A, %d-%b-%y %T GMT\"\
    ['${rfc850}'] = function(self) return self:fmt0(\"%A, %d-%b-%y %T GMT\") end,\
    -- RFC1123 format, same as \"%a, %d %b %Y %T GMT\"\
    ['${rfc1123}'] = function(self) return self:fmt0(\"%a, %d %b %Y %T GMT\") end,\
    -- asctime format, same as \"%a %b %d %T %Y\"\
    ['${asctime}'] = function(self) return self:fmt0(\"%a %b %d %T %Y\") end,\
  }\
  function dobj:fmt0(str) return (gsub(str, \"%%[%a%%\\b\\f]\", function(x) local f = tvspec[x];return (f and f(self)) or x end)) end\
  function dobj:fmt(str)\
    str = str or self.fmtstr or fmtstr\
    return self:fmt0((gmatch(str, \"${%w+}\")) and (gsub(str, \"${%w+}\", function(x)local f=tvspec[x];return (f and f(self)) or x end)) or str)\
  end\
\
  function dobj.__lt(a, b) if (a.daynum == b.daynum) then return (a.dayfrc < b.dayfrc) else return (a.daynum < b.daynum) end end\
  function dobj.__le(a, b) if (a.daynum == b.daynum) then return (a.dayfrc <= b.dayfrc) else return (a.daynum <= b.daynum) end end\
  function dobj.__eq(a, b)return (a.daynum == b.daynum) and (a.dayfrc == b.dayfrc) end\
  function dobj.__sub(a,b)\
    local d1, d2 = date_getdobj(a), date_getdobj(b)\
    local d0 = d1 and d2 and date_new(d1.daynum - d2.daynum, d1.dayfrc - d2.dayfrc)\
    return d0 and d0:normalize()\
  end\
  function dobj.__add(a,b)\
    local d1, d2 = date_getdobj(a), date_getdobj(b)\
    local d0 = d1 and d2 and date_new(d1.daynum + d2.daynum, d1.dayfrc + d2.dayfrc)\
    return d0 and d0:normalize()\
  end\
  function dobj.__concat(a, b) return tostring(a) .. tostring(b) end\
  function dobj:__tostring() return self:fmt() end\
\
  function dobj:copy() return date_new(self.daynum, self.dayfrc) end\
\
--[[ THE LOCAL DATE OBJECT METHODS ]]--\
  function dobj:tolocal()\
    local dn,df = self.daynum, self.dayfrc\
    local bias  = getbiasutc2(self)\
    if bias then\
      -- utc = local + bias; local = utc - bias\
      self.daynum = dn\
      self.dayfrc = df - bias*TICKSPERSEC\
      return self:normalize()\
    else\
      return nil\
    end\
  end\
\
  function dobj:toutc()\
    local dn,df = self.daynum, self.dayfrc\
    local bias  = getbiasloc2(dn, df)\
    if bias then\
      -- utc = local + bias;\
      self.daynum = dn\
      self.dayfrc = df + bias*TICKSPERSEC\
      return self:normalize()\
    else\
      return nil\
    end\
  end\
\
  function dobj:getbias()  return (getbiasloc2(self.daynum, self.dayfrc))/SECPERMIN end\
\
  function dobj:gettzname()\
    local _, tvu, _ = getbiasloc2(self.daynum, self.dayfrc)\
    return tvu and osdate(\"%Z\",tvu) or \"\"\
  end\
\
--#if not DATE_OBJECT_AFX then\
  function date.time(h, r, s, t)\
    h, r, s, t = tonumber(h or 0), tonumber(r or 0), tonumber(s or 0), tonumber(t or 0)\
    if h and r and s and t then\
       return date_new(DAYNUM_DEF, makedayfrc(h, r, s, t))\
    else\
      return date_error_arg()\
    end\
  end\
\
  function date:__call(...)\
    local arg = pack(...)\
    if arg.n  > 1 then return (date_from(...))\
    elseif arg.n == 0 then return (date_getdobj(false))\
    else local o, r = date_getdobj(arg[1]);  return r and o:copy() or o end\
  end\
\
  date.diff = dobj.__sub\
\
  function date.isleapyear(v)\
    local y = fix(v);\
    if not y then\
      y = date_getdobj(v)\
      y = y and y:getyear()\
    end\
    return isleapyear(y+0)\
  end\
\
  function date.epoch() return date_epoch:copy()  end\
\
  function date.isodate(y,w,d) return date_new(makedaynum_isoywd(y + 0, w and (w+0) or 1, d and (d+0) or 1), 0)  end\
\
-- Internal functions\
  function date.fmt(str) if str then fmtstr = str end; return fmtstr end\
  function date.daynummin(n)  DAYNUM_MIN = (n and n < DAYNUM_MAX) and n or DAYNUM_MIN  return n and DAYNUM_MIN or date_new(DAYNUM_MIN, 0):normalize()end\
  function date.daynummax(n)  DAYNUM_MAX = (n and n > DAYNUM_MIN) and n or DAYNUM_MAX return n and DAYNUM_MAX or date_new(DAYNUM_MAX, 0):normalize()end\
  function date.ticks(t) if t then setticks(t) end return TICKSPERSEC  end\
--#end -- not DATE_OBJECT_AFX\
\
  local tm = osdate(\"!*t\", 0);\
  if tm then\
    date_epoch = date_new(makedaynum(tm.year, tm.month - 1, tm.day), makedayfrc(tm.hour, tm.min, tm.sec, 0))\
    -- the distance from our epoch to os epoch in daynum\
    DATE_EPOCH = date_epoch and date_epoch:spandays()\
  else -- error will be raise only if called!\
    date_epoch = setmetatable({},{__index = function() error(\"failed to get the epoch date\") end})\
  end\
\
--#if not DATE_OBJECT_AFX then\
return date\
--#else\
--$return date_from\
--#end\
\
"
, '@'.."/Users/andrewmorgan/torch/install/share/lua/5.1/date.lua" ) )






package.preload[ "csv" ] = assert( (loadstring or load)(
"--- Read a comma or tab (or other delimiter) separated file.\
--  This version of a CSV reader differs from others I've seen in that it\
--\
--  + handles embedded newlines in fields (if they're delimited with double\
--    quotes)\
--  + is line-ending agnostic\
--  + reads the file line-by-line, so it can potientially handle large\
--    files.\
--\
--  Of course, for such a simple format, CSV is horribly complicated, so it\
--  likely gets something wrong.\
\
--  (c) Copyright 2013-2014 Incremental IP Limited.\
--  (c) Copyright 2014 Kevin Martin\
--  Available under the MIT licence.  See LICENSE for more information.\
\
-- local DEFAULT_BUFFER_BLOCK_SIZE = 1024 * 1024\
local DEFAULT_BUFFER_BLOCK_SIZE = 1024\
\
------------------------------------------------------------------------------\
\
local function trim_space(s)\
  return s:match(\"^%s*(.-)%s*$\")\
end\
\
\
local function fix_quotes(s)\
  -- the sub(..., -2) is to strip the trailing quote\
  return string.sub(s:gsub('\"\"', '\"'), 1, -2)\
end\
\
\
------------------------------------------------------------------------------\
\
local column_map = {}\
column_map.__index = column_map\
\
--- Parse a list of columns.\
--  The main job here is normalising column names and dealing with columns\
--  for which we have more than one possible name in the header.\
function column_map:new(columns)\
  local name_map = {}\
  for n, v in pairs(columns) do\
    local names\
    local t\
    if type(v) == \"table\" then\
      t = { transform = v.transform, default = v.default }\
      if v.name then\
        names = { (v.name:gsub(\"[^%w%d]+\", \" \")) }\
      elseif v.names then\
        names = v.names\
        for i, n in ipairs(names) do names[i] = n:gsub(\"[^%w%d]+\", \" \") end\
      end\
    else\
      if type(v) == \"function\" then\
        t = { transform = v }\
      else\
        t = {}\
      end\
    end\
\
    if not names then\
      names = { (n:lower():gsub(\"[^%w%d]+\", \" \")) }\
    end\
\
    t.name = n\
    for _, n in ipairs(names) do\
      name_map[n:lower()] = t\
    end\
  end\
\
  return setmetatable({ name_map = name_map }, column_map)\
end\
\
\
--- Map \"virtual\" columns to file columns.\
--  Once we've read the header, work out which columns we're interested in and\
--  what to do with them.  Mostly this is about checking we've got the columns\
--  we need and writing a nice complaint if we haven't.\
function column_map:read_header(header)\
  local index_map = {}\
\
  -- Match the columns in the file to the columns in the name map\
  local found = {}\
  local found_any\
  for i, word in ipairs(header) do\
    word = word:lower():gsub(\"[^%w%d]+\", \" \"):gsub(\"^ *(.-) *$\", \"%1\")\
    local r = self.name_map[word]\
    if r then\
      index_map[i] = r\
      found[r.name] = true\
      found_any = true\
    end\
  end\
\
  if not found_any then return end\
\
  -- check we found all the columns we need\
  local not_found = {}\
  for name, r in pairs(self.name_map) do\
    if not found[r.name] then\
      local nf = not_found[r.name]\
      if nf then\
        nf[#nf+1] = name\
      else\
        not_found[r.name] = { name }\
      end\
    end\
  end\
  -- If any columns are missing, assemble an error message\
  if next(not_found) then\
    local problems = {}\
    for k, v in pairs(not_found) do\
      local missing\
      if #v == 1 then\
        missing = \"'\"..v[1]..\"'\"\
      else\
        missing = v[1]\
        for i = 2, #v - 1 do\
          missing = missing..\", '\"..v[i]..\"'\"\
        end\
        missing = missing..\" or '\"..v[#v]..\"'\"\
      end\
      problems[#problems+1] = \"Couldn't find a column named \"..missing\
    end\
    error(table.concat(problems, \"\\n\"), 0)\
  end\
\
  self.index_map = index_map\
  return true\
end\
\
\
function column_map:transform(value, index)\
  local field = self.index_map[index]\
  if field then\
    if field.transform then\
      local ok\
      ok, value = pcall(field.transform, value)\
      if not ok then\
        error((\"Error reading field '%s': %s\"):format(field.name, value), 0)\
      end\
    end\
    return value or field.default, field.name\
  end\
end\
\
\
------------------------------------------------------------------------------\
\
local file_buffer = {}\
file_buffer.__index = file_buffer\
\
function file_buffer:new(file, buffer_block_size)\
  return setmetatable({\
      file              = file,\
      buffer_block_size = buffer_block_size or DEFAULT_BUFFER_BLOCK_SIZE,\
      buffer_start      = 0,\
      buffer            = \"\",\
    }, file_buffer)\
end\
\
\
--- Cut the front off the buffer if we've already read it\
function file_buffer:truncate(p)\
  p = p - self.buffer_start\
  if p > self.buffer_block_size then\
    local remove = self.buffer_block_size *\
      math.floor((p-1) / self.buffer_block_size)\
    self.buffer = self.buffer:sub(remove + 1)\
    self.buffer_start = self.buffer_start + remove\
  end\
end\
\
\
--- Find something in the buffer, extending it if necessary\
function file_buffer:find(pattern, init)\
  while true do\
    local first, last, capture =\
      self.buffer:find(pattern, init - self.buffer_start)\
    -- if we found nothing, or the last character is at the end of the\
    -- buffer (and the match could potentially be longer) then read some\
    -- more.\
    if not first or last == #self.buffer then\
      local s = self.file:read(self.buffer_block_size)\
      if not s then\
        if not first then\
          return\
        else\
          return first + self.buffer_start, last + self.buffer_start, capture\
        end\
      end\
      self.buffer = self.buffer..s\
    else\
      return first + self.buffer_start, last + self.buffer_start, capture\
    end\
  end\
end\
\
\
--- Extend the buffer so we can see more\
function file_buffer:extend(offset)\
  local extra = offset - #self.buffer - self.buffer_start\
  if extra > 0 then\
    local size = self.buffer_block_size *\
      math.ceil(extra / self.buffer_block_size)\
    local s = self.file:read(size)\
    if not s then return end\
    self.buffer = self.buffer..s\
  end\
end\
\
\
--- Get a substring from the buffer, extending it if necessary\
function file_buffer:sub(a, b)\
  self:extend(b)\
  b = b == -1 and b or b - self.buffer_start\
  return self.buffer:sub(a - self.buffer_start, b)\
end\
\
\
--- Close a file buffer\
function file_buffer:close()\
  self.file:close()\
  self.file = nil\
end\
\
\
------------------------------------------------------------------------------\
\
-- I adjusted delimiter list below\
local separator_candidates = { \"\\30\", \"\\t\", \",\", \"|\", \";\" } \
local guess_separator_params = { record_limit = 8; }\
\
\
local function try_separator(buffer, sep, f)\
  guess_separator_params.separator = sep\
  local min, max = math.huge, 0\
  local lines, split_lines = 0, 0\
  local iterator = coroutine.wrap(function() f(buffer, guess_separator_params) end)\
  for t in iterator do\
    min = math.min(min, #t)\
    max = math.max(max, #t)\
    split_lines = split_lines + (t[2] and 1 or 0)\
    lines = lines + 1\
  end\
  if split_lines / lines > 0.75 then\
    return max - min\
  else\
    return math.huge\
  end\
end\
\
\
--- If the user hasn't specified a separator, try to work out what it is.\
function guess_separator(buffer, f)\
  local best_separator, lowest_diff = \"\", math.huge\
  for _, s in ipairs(separator_candidates) do\
    local ok, diff = pcall(function() return try_separator(buffer, s, f) end)\
    if ok and diff < lowest_diff then\
      best_separator = s\
      lowest_diff = diff\
    end\
  end\
\
  return best_separator\
end\
\
\
local unicode_BOMS =\
{\
  {\
    length = 2,\
    BOMS =\
    {\
      [\"\\254\\255\"]      = true, -- UTF-16 big-endian\
      [\"\\255\\254\"]      = true, -- UTF-16 little-endian\
    }\
  },\
  {\
    length = 3,\
    BOMS =\
    {\
      [\"\\239\\187\\191\"]  = true, -- UTF-8\
    }\
  }\
}\
\
\
local function find_unicode_BOM(sub)\
  for _, x in ipairs(unicode_BOMS) do\
    local code = sub(1, x.length)\
    if x.BOMS[code] then\
      return x.length\
    end\
  end\
  return 0\
end\
\
\
--- Iterate through the records in a file\
--  Since records might be more than one line (if there's a newline in quotes)\
--  and line-endings might not be native, we read the file in chunks of\
--  we read the file in chunks using a file_buffer, rather than line-by-line\
--  using io.lines.\
local function separated_values_iterator(buffer, parameters)\
  local field_start = 1\
\
  local advance\
  if buffer.truncate then\
    advance = function(n)\
      field_start = field_start + n\
      buffer:truncate(field_start)\
    end\
  else\
    advance = function(n)\
      field_start = field_start + n\
    end\
  end\
\
\
  local function field_sub(a, b)\
    b = b == -1 and b or b + field_start - 1\
    return buffer:sub(a + field_start - 1, b)\
  end\
\
\
  local function field_find(pattern, init)\
    init = init or 1\
    local f, l, c = buffer:find(pattern, init + field_start - 1)\
    if not f then return end\
    return f - field_start + 1, l - field_start + 1, c\
  end\
\
\
  -- Is there some kind of Unicode BOM here?\
  advance(find_unicode_BOM(field_sub))\
\
\
  -- Start reading the file\
  local sep = \"([\"..(parameters.separator or\
                     guess_separator(buffer, separated_values_iterator))..\"\\n\\r])\"\
  local line_start = 1\
  local line = 1\
  local field_count, fields, starts, nonblanks = 0, {}, {}\
  local header, header_read\
  local field_start_line, field_start_column\
  local record_count = 0\
\
\
  local function problem(message)\
    error((\"%s:%d:%d: %s\"):\
      format(parameters.filename, field_start_line, field_start_column,\
             message), 0)\
  end\
\
\
  while true do\
    local field_end, sep_end, this_sep\
    local tidy\
    field_start_line = line\
    field_start_column = field_start - line_start + 1\
\
    -- If the field is quoted, go find the other quote\
    if field_sub(1, 1) == '\"' then\
      advance(1)\
      local current_pos = 0\
      repeat\
        local a, b, c = field_find('\"(\"?)', current_pos + 1)\
        current_pos = b\
      until c ~= '\"'\
      if not current_pos then problem(\"unmatched quote\") end\
      tidy = fix_quotes\
      field_end, sep_end, this_sep = field_find(\" *([^ ])\", current_pos+1)\
      if this_sep and not this_sep:match(sep) then problem(\"unmatched quote\") end\
    else\
      field_end, sep_end, this_sep = field_find(sep, 1)\
      tidy = trim_space\
    end\
\
    -- Look for the separator or a newline or the end of the file\
    field_end = (field_end or 0) - 1\
\
    -- Read the field, then convert all the line endings to \\n, and\
    -- count any embedded line endings\
    local value = field_sub(1, field_end)\
    value = value:gsub(\"\\r\\n\", \"\\n\"):gsub(\"\\r\", \"\\n\")\
    for nl in value:gmatch(\"\\n()\") do\
      line = line + 1\
      line_start = nl + field_start\
    end\
\
    value = tidy(value)\
    if #value > 0 then nonblanks = true end\
    field_count = field_count + 1\
\
    -- Insert the value into the table for this \"line\"\
    local key\
    if parameters.column_map and header_read then\
      local ok\
      ok, value, key = pcall(parameters.column_map.transform,\
        parameters.column_map, value, field_count)\
      if not ok then problem(value) end\
    elseif header then\
      key = header[field_count]\
    else\
      key = field_count\
    end\
    if key then\
      fields[key] = value\
      starts[key] = { line=field_start_line, column=field_start_column }\
    end\
\
    -- if we ended on a newline then yield the fields on this line.\
    if not this_sep or this_sep == \"\\r\" or this_sep == \"\\n\" then\
      if parameters.column_map and not header_read then\
        header_read = parameters.column_map:read_header(fields)\
      elseif parameters.header and not header then\
        if nonblanks or field_count > 1 then -- ignore blank lines\
          header = fields\
          header_read = true\
        end\
      else\
        if nonblanks or field_count > 1 then -- ignore blank lines\
          coroutine.yield(fields, starts)\
          record_count = record_count + 1\
          if parameters.record_limit and\
             record_count >= parameters.record_limit then\
            break\
          end\
        end\
      end\
      field_count, fields, starts, nonblanks = 0, {}, {}\
    end\
\
    -- If we *really* didn't find a separator then we're done.\
    if not sep_end then break end\
\
    -- If we ended on a newline then count it.\
    if this_sep == \"\\r\" or this_sep == \"\\n\" then\
      if this_sep == \"\\r\" and field_sub(sep_end+1, sep_end+1) == \"\\n\" then\
        sep_end = sep_end + 1\
      end\
      line = line + 1\
      line_start = field_start + sep_end\
    end\
\
    advance(sep_end)\
  end\
end\
\
\
------------------------------------------------------------------------------\
\
local buffer_mt =\
{\
  lines = function(t)\
      return coroutine.wrap(function()\
          separated_values_iterator(t.buffer, t.parameters)\
        end)\
    end,\
  close = function(t)\
      if t.buffer.close then t.buffer:close() end\
    end,\
  name = function(t)\
      return t.parameters.filename\
    end,\
}\
buffer_mt.__index = buffer_mt\
\
\
--- Use an existing file or buffer as a stream to read csv from.\
--  (A buffer is just something that looks like a string in that we can do\
--  `buffer:sub()` and `buffer:find()`)\
--  @return a file object\
local function use(\
  buffer,           -- ?string|file|buffer: the buffer to read from.  If it's:\
                    --   - a string, read from that;\
                    --   - a file, turn it into a file_buffer;\
                    --   - nil, read from stdin\
                    -- otherwise assume it's already a a buffer.\
  parameters)       -- ?table: parameters controlling reading the file.\
                    -- See README.md\
  parameters = parameters or {}\
  parameters.filename = parameters.filename or \"<unknown>\"\
  parameters.column_map = parameters.columns and\
    column_map:new(parameters.columns)\
\
  if not buffer then\
    buffer = file_buffer:new(io.stdin)\
  elseif io.type(buffer) == \"file\" then\
    buffer = file_buffer:new(buffer)\
  end\
\
  local f = { buffer = buffer, parameters = parameters }\
  return setmetatable(f, buffer_mt)\
end\
\
\
------------------------------------------------------------------------------\
\
--- Open a file for reading as a delimited file\
--  @return a file object\
local function open(\
  filename,         -- string: name of the file to open\
  parameters)       -- ?table: parameters controlling reading the file.\
                    -- See README.md\
  local file, message = io.open(filename, \"r\")\
  if not file then return nil, message end\
\
  parameters = parameters or {}\
  parameters.filename = filename\
  return use(file_buffer:new(file), parameters)\
end\
\
\
------------------------------------------------------------------------------\
\
local function makename(s)\
  local t = {}\
  t[#t+1] = \"<(String) \"\
  t[#t+1] = (s:gmatch(\"[^\\n]+\")() or \"\"):sub(1,15)\
  if #t[#t] > 14 then t[#t+1] = \"...\" end\
  t[#t+1] = \" >\"\
  return table.concat(t)\
end\
\
\
--- Open a string for reading as a delimited file\
--  @return a file object\
local function openstring(\
  filecontents,     -- string: The contents of the delimited file\
  parameters)       -- ?table: parameters controlling reading the file.\
                    -- See README.md\
\
  parameters = parameters or {}\
\
\
  parameters.filename = parameters.filename or makename(s)\
  parameters.buffer_size = parameters.buffer_size or #filecontents\
  return use(filecontents, parameters)\
end\
\
\
------------------------------------------------------------------------------\
\
return { open = open, openstring = openstring, use = use }\
\
------------------------------------------------------------------------------\
"
, '@'.."/opt/local/share/luarocks/share/lua/5.2/csv.lua" ) )

package.preload[ "pl.lapp" ] = assert( (loadstring or load)(
"--- Simple command-line parsing using human-readable specification.\
-- Supports GNU-style parameters.\
--\
--      lapp = require 'pl.lapp'\
--      local args = lapp [[\
--      Does some calculations\
--        -o,--offset (default 0.0)  Offset to add to scaled number\
--        -s,--scale  (number)  Scaling factor\
--         <number>; (number )  Number to be scaled\
--      ]]\
--\
--      print(args.offset + args.scale * args.number)\
--\
-- Lines begining with '-' are flags; there may be a short and a long name;\
-- lines begining wih '<var>' are arguments.  Anything in parens after\
-- the flag/argument is either a default, a type name or a range constraint.\
--\
-- See @{08-additional.md.Command_line_Programs_with_Lapp|the Guide}\
--\
-- Dependencies: `pl.sip`\
-- @module pl.lapp\
\
local status,sip = pcall(require,'pl.sip')\
if not status then\
    sip = require 'sip'\
end\
local match = sip.match_at_start\
local append,tinsert = table.insert,table.insert\
\
sip.custom_pattern('X','(%a[%w_%-]*)')\
\
local function lines(s) return s:gmatch('([^\\n]*)\\n') end\
local function lstrip(str)  return str:gsub('^%s+','')  end\
local function strip(str)  return lstrip(str):gsub('%s+$','') end\
local function at(s,k)  return s:sub(k,k) end\
local function isdigit(s) return s:find('^%d+$') == 1 end\
\
local lapp = {}\
\
local open_files,parms,aliases,parmlist,usage,windows,script\
\
lapp.callback = false -- keep Strict happy\
\
local filetypes = {\
    stdin = {io.stdin,'file-in'}, stdout = {io.stdout,'file-out'},\
    stderr = {io.stderr,'file-out'}\
}\
\
--- controls whether to dump usage on error.\
-- Defaults to true\
lapp.show_usage_error = true\
\
--- quit this script immediately.\
-- @param msg optional message\
-- @param no_usage suppress 'usage' display\
function lapp.quit(msg,no_usage)\
    if no_usage == 'throw' then\
        error(msg)\
    end\
    if msg then\
        io.stderr:write(msg..'\\n\\n')\
    end\
    if not no_usage then\
        io.stderr:write(usage)\
    end\
    os.exit(1)\
end\
\
--- print an error to stderr and quit.\
-- @param msg a message\
-- @param no_usage suppress 'usage' display\
function lapp.error(msg,no_usage)\
    if not lapp.show_usage_error then\
        no_usage = true\
    elseif lapp.show_usage_error == 'throw' then\
        no_usage = 'throw'\
    end\
    lapp.quit(script..': '..msg,no_usage)\
end\
\
--- open a file.\
-- This will quit on error, and keep a list of file objects for later cleanup.\
-- @param file filename\
-- @param opt same as second parameter of <code>io.open</code>\
function lapp.open (file,opt)\
    local val,err = io.open(file,opt)\
    if not val then lapp.error(err,true) end\
    append(open_files,val)\
    return val\
end\
\
--- quit if the condition is false.\
-- @param condn a condition\
-- @param msg an optional message\
function lapp.assert(condn,msg)\
    if not condn then\
        lapp.error(msg)\
    end\
end\
\
local function range_check(x,min,max,parm)\
    lapp.assert(min <= x and max >= x,parm..' out of range')\
end\
\
local function xtonumber(s)\
    local val = tonumber(s)\
    if not val then lapp.error(\"unable to convert to number: \"..s) end\
    return val\
end\
\
local types = {}\
\
local builtin_types = {string=true,number=true,['file-in']='file',['file-out']='file',boolean=true}\
\
local function convert_parameter(ps,val)\
    if ps.converter then\
        val = ps.converter(val)\
    end\
    if ps.type == 'number' then\
        val = xtonumber(val)\
    elseif builtin_types[ps.type] == 'file' then\
        val = lapp.open(val,(ps.type == 'file-in' and 'r') or 'w' )\
    elseif ps.type == 'boolean' then\
        return val\
    end\
    if ps.constraint then\
        ps.constraint(val)\
    end\
    return val\
end\
\
--- add a new type to Lapp. These appear in parens after the value like\
-- a range constraint, e.g. '<ival> (integer) Process PID'\
-- @param name name of type\
-- @param converter either a function to convert values, or a Lua type name.\
-- @param constraint optional function to verify values, should use lapp.error\
-- if failed.\
function lapp.add_type (name,converter,constraint)\
    types[name] = {converter=converter,constraint=constraint}\
end\
\
local function force_short(short)\
    lapp.assert(#short==1,short..\": short parameters should be one character\")\
end\
\
-- deducing type of variable from default value;\
local function process_default (sval,vtype)\
    local val\
    if not vtype or vtype == 'number' then\
        val = tonumber(sval)\
    end\
    if val then -- we have a number!\
        return val,'number'\
    elseif filetypes[sval] then\
        local ft = filetypes[sval]\
        return ft[1],ft[2]\
    else\
        if sval == 'true' and not vtype then\
            return true, 'boolean'\
        end\
        if sval:match '^[\"\\']' then sval = sval:sub(2,-2) end\
        return sval,vtype or 'string'\
    end\
end\
\
--- process a Lapp options string.\
-- Usually called as lapp().\
-- @param str the options text\
-- @param args a table of arguments (default is `_G.arg`)\
-- @return a table with parameter-value pairs\
function lapp.process_options_string(str,args)\
    local results = {}\
    local opts = {at_start=true}\
    local varargs\
    local arg = args or _G.arg\
    open_files = {}\
    parms = {}\
    aliases = {}\
    parmlist = {}\
\
    local function check_varargs(s)\
        local res,cnt = s:gsub('^%.%.%.%s*','')\
        return res, (cnt > 0)\
    end\
\
    local function set_result(ps,parm,val)\
        parm = type(parm) == \"string\" and parm:gsub(\"%W\", \"_\") or parm -- so foo-bar becomes foo_bar in Lua\
        if not ps.varargs then\
            results[parm] = val\
        else\
            if not results[parm] then\
                results[parm] = { val }\
            else\
                append(results[parm],val)\
            end\
        end\
    end\
\
    usage = str\
\
    for line in lines(str) do\
        local res = {}\
        local optspec,optparm,i1,i2,defval,vtype,constraint,rest\
        line = lstrip(line)\
        local function check(str)\
            return match(str,line,res)\
        end\
\
        -- flags: either '-<short>', '-<short>,--<long>' or '--<long>'\
        if check '-$v{short}, --$o{long} $' or check '-$v{short} $' or check '--$o{long} $' then\
            if res.long then\
                optparm = res.long:gsub('[^%w%-]','_')  -- I'm not sure the $o pattern will let anything else through?\
                if res.short then aliases[res.short] = optparm  end\
            else\
                optparm = res.short\
            end\
            if res.short and not lapp.slack then force_short(res.short) end\
            res.rest, varargs = check_varargs(res.rest)\
        elseif check '$<{name} $'  then -- is it <parameter_name>?\
            -- so <input file...> becomes input_file ...\
            optparm,rest = res.name:match '([^%.]+)(.*)'\
            optparm = optparm:gsub('%A','_')\
            varargs = rest == '...'\
            append(parmlist,optparm)\
        end\
        -- this is not a pure doc line and specifies the flag/parameter type\
        if res.rest then\
            line = res.rest\
            res = {}\
            local optional\
            -- do we have ([optional] [<type>] [default <val>])?\
            if match('$({def} $',line,res) or match('$({def}',line,res) then\
                local typespec = strip(res.def)\
                local ftype, rest = typespec:match('^(%S+)(.*)$')\
                rest = strip(rest)\
                if ftype == 'optional' then\
                    ftype, rest = rest:match('^(%S+)(.*)$')\
                    rest = strip(rest)\
                    optional = true\
                end\
                local default\
                if ftype == 'default' then\
                    default = true\
                    if rest == '' then lapp.error(\"value must follow default\") end\
                else -- a type specification\
                    if match('$f{min}..$f{max}',ftype,res) then\
                        -- a numerical range like 1..10\
                        local min,max = res.min,res.max\
                        vtype = 'number'\
                        constraint = function(x)\
                            range_check(x,min,max,optparm)\
                        end\
                    elseif not ftype:match '|' then -- plain type\
                        vtype = ftype\
                    else\
                        -- 'enum' type is a string which must belong to\
                        -- one of several distinct values\
                        local enums = ftype\
                        local enump = '|' .. enums .. '|'\
                        vtype = 'string'\
                        constraint = function(s)\
                            lapp.assert(enump:match('|'..s..'|'),\
                              \"value '\"..s..\"' not in \"..enums\
                            )\
                        end\
                    end\
                end\
                res.rest = rest\
                typespec = res.rest\
                -- optional 'default value' clause. Type is inferred as\
                -- 'string' or 'number' if there's no explicit type\
                if default or match('default $r{rest}',typespec,res) then\
                    defval,vtype = process_default(res.rest,vtype)\
                end\
            else -- must be a plain flag, no extra parameter required\
                defval = false\
                vtype = 'boolean'\
            end\
            local ps = {\
                type = vtype,\
                defval = defval,\
                required = defval == nil and not optional,\
                comment = res.rest or optparm,\
                constraint = constraint,\
                varargs = varargs\
            }\
            varargs = nil\
            if types[vtype] then\
                local converter = types[vtype].converter\
                if type(converter) == 'string' then\
                    ps.type = converter\
                else\
                    ps.converter = converter\
                end\
                ps.constraint = types[vtype].constraint\
            elseif not builtin_types[vtype] then\
                lapp.error(vtype..\" is unknown type\")\
            end\
            parms[optparm] = ps\
        end\
    end\
    -- cool, we have our parms, let's parse the command line args\
    local iparm = 1\
    local iextra = 1\
    local i = 1\
    local parm,ps,val\
\
    local function check_parm (parm)\
        local eqi = parm:find '='\
        if eqi then\
            tinsert(arg,i+1,parm:sub(eqi+1))\
            parm = parm:sub(1,eqi-1)\
        end\
        return parm,eqi\
    end\
\
    local function is_flag (parm)\
        return parms[aliases[parm] or parm]\
    end\
\
    while i <= #arg do\
        local theArg = arg[i]\
        local res = {}\
        -- look for a flag, -<short flags> or --<long flag>\
        if match('--$S{long}',theArg,res) or match('-$S{short}',theArg,res) then\
            if res.long then -- long option\
                parm = check_parm(res.long)\
            elseif #res.short == 1 or is_flag(res.short) then\
                parm = res.short\
            else\
                local parmstr,eq = check_parm(res.short)\
                if not eq then\
                    parm = at(parmstr,1)\
                    local flag = is_flag(parm)\
                    if flag.type ~= 'boolean' then\
                    --if isdigit(at(parmstr,2)) then\
                        -- a short option followed by a digit is an exception (for AW;))\
                        -- push ahead into the arg array\
                        tinsert(arg,i+1,parmstr:sub(2))\
                    else\
                        -- push multiple flags into the arg array!\
                        for k = 2,#parmstr do\
                            tinsert(arg,i+k-1,'-'..at(parmstr,k))\
                        end\
                    end\
                else\
                    parm = parmstr\
                end\
            end\
            if aliases[parm] then parm = aliases[parm] end\
            if not parms[parm] and (parm == 'h' or parm == 'help') then\
                lapp.quit()\
            end\
        else -- a parameter\
            parm = parmlist[iparm]\
            if not parm then\
               -- extra unnamed parameters are indexed starting at 1\
               parm = iextra\
               ps = { type = 'string' }\
               parms[parm] = ps\
               iextra = iextra + 1\
            else\
                ps = parms[parm]\
            end\
            if not ps.varargs then\
                iparm = iparm + 1\
            end\
            val = theArg\
        end\
        ps = parms[parm]\
        if not ps then lapp.error(\"unrecognized parameter: \"..parm) end\
        if ps.type ~= 'boolean' then -- we need a value! This should follow\
            if not val then\
                i = i + 1\
                val = arg[i]\
            end\
            lapp.assert(val,parm..\" was expecting a value\")\
        else -- toggle boolean flags (usually false -> true)\
            val = not ps.defval\
        end\
        ps.used = true\
        val = convert_parameter(ps,val)\
        set_result(ps,parm,val)\
        if builtin_types[ps.type] == 'file' then\
            set_result(ps,parm..'_name',theArg)\
        end\
        if lapp.callback then\
            lapp.callback(parm,theArg,res)\
        end\
        i = i + 1\
        val = nil\
    end\
    -- check unused parms, set defaults and check if any required parameters were missed\
    for parm,ps in pairs(parms) do\
        if not ps.used then\
            if ps.required then lapp.error(\"missing required parameter: \"..parm) end\
            set_result(ps,parm,ps.defval)\
        end\
    end\
    return results\
end\
\
if arg then\
    script = arg[0]:gsub('.+[\\\\/]',''):gsub('%.%a+$','')\
else\
    script = \"inter\"\
end\
\
\
setmetatable(lapp, {\
    __call = function(tbl,str,args) return lapp.process_options_string(str,args) end,\
})\
\
\
return lapp\
\
\
"
, '@'.."/opt/local/share/luarocks/share/lua/5.2/pl/lapp.lua" ) )











--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END OF EMBEDDED LIBRARY CODE. pl.lapp, csv, date. XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



                  -- Libraries --
-- pcall(require, "strict")

local require = require

local csv = require 'csv'
local date = require 'date'
local lapp = require 'pl.lapp'

      -- require penlight, so later I can make this parameter driven off the command line more nicely
      -- require("pl")
      -- load penlight to use the command line args
      -- load pl.pretty and pl.slack as helpers
      -- require date, to use time period calculation functions

-- this is only needed when troubleshooting
-- local pretty = require 'pl.pretty'


lapp.slack = true
-- set lapp.slack to true to enable multicharacter options on commandline.

 
-- configure the penlight Lapp Framework options parser
-- this sets out the command line options that control the script

local args = lapp [[
  Options
   -v --help                          Show version and help
   -F (string default ",")            input record delimeter
   -OFS (string default ",")          the output record delimeter
   -h --header                        indicates there is a column header row on input
   -H --outheader                     indicate if you want an output header record
   -f (string default "<stdin>")      input file to process
   -s --stats                         print enhanced trend statistics
   -p (default 1)                     user value indicating the pass of the algo over the data             
]]

                  -- BEGIN --

--- print help 
--  print out the version and help info when called using -v option on command line
if args.v == true or args.version == true 
  then print(whohow) 
  os.exit()
end
  
--- Read sequenced timeseries data via 'csv' package
--  first pass the file/stdin into the csv library using csv.use function. 
--  if the filename is <stdin>, set to nil, as down in the csv code it will default read stdin. 
--  Leaving args.f as stdin allows tests later on when we open the file.

local params ={}
params.header = args.h
params.separator = args.F
if args.f == "<stdin>" then 
  params.filename = nil
else
  params.filename = args.f
end 


-- set out the FileHeaders I accept from the commandline, and remap ones that come in wrong to match our code.
--                                    IF YOU HAVE OTHER COLUMN ALIASES, REMAP THE COLUMN NAMES HERE
params.columns = { 
     ric = {names = {"ts_id", "ric"}}
   , opendate = {names = {"opendate", "open_date"}}
   , closedate = {names = {"closedate", "close_date"}}
   , offsetdate = {names = {"offsetdate", "offset_date"}}
   , offset = {names = {"offset"}}
   , split = {names = {"split"}}
   , timeframe = {names = {"timeframe"}}
   , measure = {names = {"measure"}}
   , first = {names = {"first"}}
   , high = {names = {"high"}}
   , low = {names = {"low"}}
   , second = {names = {"second"}}
   , highdate = {names = {"high_date", "highdate"}}
   , lowdate = {names = {"low_date", "lowdate"}}
   , firstdate = {names = {"first_date", "firstdate"}}
   , seconddate = {names = {"second_date", "seconddate", "2nddate"}} 
   , trend = {names = {"trend", "wave"}} 
   
}
-- the column names are fixed to standard FHLS output file, created with the -H 
-- ts_id,opendate,closedate,offsetdate,offset,split,timeframe,measure,first,high,low,second,high_date,low_date,first_date,second_date, trend

--- start to prep the file I want to convert

local data = assert(csv.use(args.f, params))
-- this command builds the csv processing "pipeline" configurations through the buffers
-- there are options I have not set here to optimise the buffer chunk size etc

local f = assert(csv.openstring(data, data.parameters))
-- the above command then opens the csv buffer pipeline and code and awaits a stream input

--- enable for verbose mode
--[[  
--      pretty.dump(args)
--      print("dumping csv.use output")
--      pretty.dump(data)
--      print("dumping csv.openstring output, f")
--      pretty.dump(f)
--]]

---   It is time now to feed the pipe with data from our file input: 
--    test if the filename is nil, if so feed from stdin, else set filename, open stream.
      if args.f == "<stdin>" then -- test if the value is nil
         f =  io.stdin            -- if so, set the pipline to read from stdin
      else  
         f =  assert (io.open (data.parameters.filename , "r"))
      end      
      
      if args.p == nil then
        pass = ""
      else
        pass = args.p
      end
      
      local data = f:read("*a")
      f:close()


----------------------------- Your Function Definitions Go Here ----------------------------      
      -- UPDATE FHLS BARS
      -- here is my udpate function for a fhls record, when you add a new data point to it

local colheaders = "dummy"
if args.s == true then
   -- if the user requests trend statistics via option -s, create the column headers for them.
   colheaders = (     "open_date"            .. args.OFS ..    -- the trend's open date
                      "open"             .. args.OFS ..       -- the trend's open value 
                      "diff"              .. args.OFS ..       -- the absolute difference in value, from open to close
                      "relrtrn"            .. args.OFS ..       -- the relative return of the trend  (close - open) / open
                      "d_days"             .. args.OFS ..       -- the difference in days from trend open to close
                      "RatioToPrev"        .. args.OFS ..       -- the ratio of this trend against the one before it (of opposite direction)
                      "RatioToPPrev"                            -- the ratio of this trend against that before the previous one (of same direction) (commonly thought to be a fib ratio)
                ) 
end

      -- print header records
      if args.H == true then
          print(
          "ts_id"           .. args.OFS ..
          "date"            .. args.OFS ..
          "value"           .. args.OFS ..
          "info"            .. args.OFS ..
          "pass"            .. args.OFS ..
          "bardate"         .. args.OFS ..
          colheaders
          )
      end
      
      local function relreturn(open_value, close_value) 
          rr = (close_value - open_value)/open_value
          return rr
      end
      
----------------------------- FILE PROCESSING COMMANDS GO HERE BEGIN/ACTION/END ----------------------------   
      -- now the data should be all queued up to convert. We call the convert using 
      -- the returned objects's method, "lines"
      -- to run it by passing the local "f" or whatever you called your input stream, as the param to the method parse  
  
        --- here is the function call that starts to iterate over the parsed CSV   
        
        local function parse(streamhandle)
          --{BEGIN -- define the things to do before the file read starts here. Like Awk BEGIN

               -- global variables
               offset = 0   -- track the row numbers as an offset from the file start
               p = {}

               p.trend = 0
               prev = {}
               prev[1] = {}
               prev[2] = {}
               roffset = 0 -- the number of reversals found
                     
               
          --}{BODY - loop through the data stream.
               --you can access these fields of r: ts_id,opendate,closedate,offsetdate,offset,split,timeframe,measure,first,high,low,second,high_date,low_date,first_date,second_date,trend
               
               for r in streamhandle:lines() do            
                 offset = offset + 1
                 
                 if offset == 1 then
                 
                    -- prev is the previous reversal record, and p is the lagging FHLS bar on which we find reversal
                    -- I initialise it with the opening record of the first FHLS summary read in.
                    prev[1].date = r.opendate
                    prev[1].value = tonumber(r.measure) 
                    
                 end
                 
           
                 local currtrend = r.trend
                 
                 if r.trend == 0 or r.trend == nil then
                    -- if there's an issue, last observations carried forward (==no change, so no reversals printed)
                    currtrend = p.trend
                 end

                 
                 if currtrend ~= p.trend and offset > 1 and (currtrend ~= 0 or p.trend ~= 0 ) then
                 -- we have found a reversal in trend. Determine it's final end point, then summarise the period it covered and emit statistics about it.
                 
                       -- set the varables for the previous reversal 

                       roffset = roffset + 1
                       local RatioToPrevious = ""
                       local RatioToPrevPrevious = ""
                       
                    -- we found a top
                    if p.trend == "1" then
                       local trendvalueopen  = tonumber(prev[1].value)
                       local trendstartdate  = prev[1].date
                       -- set the valriables for the reversal we found
                       local trendvalueclose = tonumber(p.high)
                       local trendenddate  = p.highdate                                            
                       -- calculate wave statistics
                       local absValDiff = trendvalueclose - trendvalueopen                                                  -- the absolute difference in the values
                       local absTimeSpan = date(trendenddate)-date(trendstartdate)                                          -- the absolute time span of the wave
                       local relative_return = math.floor(((trendvalueclose - trendvalueopen) / trendvalueopen)*10000)/100  -- the relative return as a percent, 2 decimal places                                            
                       -- local relative_return = math.floor(((p.high - prev.value) / prev.value * 10000) + 0.5 )*100
                       if roffset > 3 then 
                            RatioToPrevious = math.floor((absValDiff / prev[1].avd)*100)/100
                            RatioToPrevPrevious = math.floor((absValDiff / prev[2].avd)*100)/100  
                       end
                       
                        -- if we asked for statistics, concate the special fields here to print them.
                        local colvalues = ""
                        if args.s == true then
                                  colvalues =  ( trendstartdate         .. args.OFS ..      -- the day the trend started
                                                 trendvalueopen         .. args.OFS ..      -- the value when the trend started
                                                 absValDiff             .. args.OFS ..      -- the absolute value change over the trend
                                                 relative_return        .. args.OFS ..      -- the relative return as a percent, 2 decimal places        
                                                 absTimeSpan:spandays() .. args.OFS ..      -- the number of days the trend lasted
                                                 RatioToPrevious        .. args.OFS ..      -- check if the trend move was a fib off previous of opposite direction
                                                 RatioToPrevPrevious    --.. args.OFS ..      -- check if the trend move was a fib off previous of same direction
                                                )
                        end
                        -- print the top                                               
                        print(
                               p.ric                  .. args.OFS ..      -- this is the timeseries id     
                               p.highdate             .. args.OFS ..      -- high date
                               p.high                 .. args.OFS ..      -- high value
                               "Top"                  .. args.OFS ..      -- this is the time frame
                               pass                   .. args.OFS ..      -- user pass id
                               p.opendate             .. args.OFS ..      -- the bar open date is the "bar date"
                               colvalues
                               
                               -- .. args.OFS .. p.highdate .. args.OFS .. prev.date --- this is the test record to check date diff working
                              )
                        -- set the current reversal as the previous one as we exit this record                         
                         prev[2] = prev[1]
                         prev[1] = {date = p.highdate, value = p.high, avd = absValDiff, rr = relative_return, ats = absTimeSpan:spandays()} 

                    -- we found a bottom    
                    elseif p.trend == "-1" then
                       local trendvalueopen  = tonumber(prev[1].value)
                       local trendstartdate  = prev[1].date
                       local trendvalueclose = tonumber(p.low)
                       local trendenddate  = p.lowdate
                       -- calculate wave statistics                        
                       local absValDiff = trendvalueclose - trendvalueopen                                                  -- the absolute difference in the values
                       local absTimeSpan = date(trendenddate)-date(trendstartdate)                                          -- the absolute time span of the wave
                       local relative_return = math.floor(((trendvalueclose - trendvalueopen) / trendvalueopen)*10000)/100  -- the relative return as a percent, 2 decimal places
                       if roffset > 3 then 
                            RatioToPrevious = math.floor((absValDiff / prev[1].avd)*100)/100
                            RatioToPrevPrevious = math.floor((absValDiff / prev[2].avd)*100)/100  
                       end
                        -- if we asked for statistics, concate the special fields here to print them.
                        local colvalues = ""
                        if args.s == true then
                                  colvalues =  ( trendstartdate         .. args.OFS ..      -- the day the trend started
                                                 trendvalueopen         .. args.OFS ..      -- the value when the trend started
                                                 absValDiff             .. args.OFS ..      -- the absolute value change over the trend
                                                 relative_return        .. args.OFS ..      -- the relative return as a percent, 2 decimal places        
                                                 absTimeSpan:spandays() .. args.OFS ..      -- the number of days the trend lasted
                                                 RatioToPrevious        .. args.OFS ..      -- check if the trend move was a fib off previous of opposite direction
                                                 RatioToPrevPrevious    --.. args.OFS ..      -- check if the trend move was a fib off previous of same direction
                                                )
                        end
                        -- print the bottom
                        print(
                               p.ric                   .. args.OFS ..     -- this is the timeseries id     
                               p.lowdate               .. args.OFS ..     -- low date
                               p.low                   .. args.OFS ..     -- low
                               "Bottom"                .. args.OFS ..     -- this is the time frame
                               pass                    .. args.OFS ..     -- user pass id
                               p.opendate              .. args.OFS ..     -- the bar open date is the "bar date"
                               colvalues
                               -- .. args.OFS .. p.lowdate .. args.OFS .. prev.date --- this is the test record to check date diff working
                              )  
                        -- set the current reversal as the previous one as we exit this record
                        prev[2] = prev[1]
                        prev[1] = {date = p.lowdate, value = p.low, avd = absValDiff, rr = relative_return, ats = absTimeSpan} 

                    end   
                 end
               -- p is a map record holding the previous FHLS record
               p = r 
               
               
               end  -- end of --  for r in streamhandle:lines() do 
          --}{END Put any additional final actions here, Like END block in Awk 
               
               streamhandle:close() -- close down the co-routine stream.
              -- print(" the total was " .. offset)
          --}
          return true
        end


---- now we have the above function, we can run it. 
-- These last two calls kickstart all the processing which happens via a coroutine 

f = csv.openstring(data, params)
local fileok = parse(f)

-- the code will end when the file is completely read and processed.


