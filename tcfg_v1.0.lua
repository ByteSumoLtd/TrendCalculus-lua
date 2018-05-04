--[[ 

 _______  ______    _______  __    _  ______     _______  _______  ___      _______  __   __  ___      __   __  _______ 
|       ||    _ |  |       ||  |  | ||      |   |       ||   _   ||   |    |       ||  | |  ||   |    |  | |  ||       |
|_     _||   | ||  |    ___||   |_| ||  _    |  |       ||  |_|  ||   |    |       ||  | |  ||   |    |  | |  ||  _____|
  |   |  |   |_||_ |   |___ |       || | |   |  |       ||       ||   |    |       ||  |_|  ||   |    |  |_|  || |_____ 
  |   |  |    __  ||    ___||  _    || |_|   |  |      _||       ||   |___ |      _||       ||   |___ |       ||_____  |
  |   |  |   |  | ||   |___ | | |   ||       |  |     |_ |   _   ||       ||     |_ |       ||       ||       | _____| |
  |___|  |___|  |_||_______||_|  |__||______|   |_______||__| |__||_______||_______||_______||_______||_______||_______|
                                                                                                                        
  TrendCalculus: Streaming Multi-Scale Trend Change Detection Algorithm

  tcfg v.1.0.1 : Trend Calculus Feature Generator.  

  Copyright 2014-2018, ByteSumo Limited (Andrew J Morgan) 

  This program implements the unsupervised "lagging labeller" functionality that extends trend calculus
  allowing users to test whether they can "beat the lag" inherent in finding trend reversals.
  It also activates a range of co-trending and leading indicator studies.

  Author:  Andrew J Morgan
  Version: 1.0.0
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

  18-04-2014
    adding in constraints to speed up development:
          reverting to only accepting STDIN
          reverting to only accepting comma delimited format
          input files expected in the standard format defined
          <stream id><value><datetime>
    pushed revision control to bitbucket

  24-06-2014
    added in options for headers, version print, named input file 
    added in logic to correctly read either named files, or from stdin
    swapped to use the CSV package, and had it fixed to work on stdin 
          usage notes:
          the code is now ready for use as a base layer for constructing further csv processing applications.
          note that any code will stream the values through the code, so processing is on files of arbitrary size.
          (that's right - big data ready)

  27-07-2014
    I have isolated just the code for the FHLS generator, and plan to test how it works with Terra compilation and 
    integration with R via the FFI foreign function interface in c. 
   
  13-03-2015
    The program now outputs first date, and second date, plus now optionally outputs special split bars     
    These outputs are tested to generate complex trends correctly downstream.
  
  27-04-2015 
    Many changes. 
      -s Enables splitbar summary production and output, making special cases transparent.
      -r Enables output of correct reversals. 

         Many performance improvements, and better comments in code.
         
  07-05-2015
    I have folded in the code for csv and pl.lapp into this code, to make the script more stand-alone for public release
    Updated the help/version page to include license and references to csv, pl.lapp, and links to their original licenses
    Updated the license to GPLv3 in the code, and help page.
    The code runs in an install of Torch7 using luajit, using luajit, or using lua 5.1 or lua 5.2

  10-06-2015
    I have corrected the public distro bug caused by not finding the pl.sip dependency by including like the other 
    embedded libraries into this code.
    
  19-08-2015 
    I have updated the tcfg program to generate great trend based features as well as prediction targets.
    Key functions that I updated where the hindsight functions, as well the relative change functions.
    I also swapped over the algorithms to track the offsets rather than the dates and then looked up the dates when needed for printing.

  05-03-2018 
    I'm editting this program to better suit Karoo_GP input format. Also adding flags - print out training files (only 5 records after turning points to emulate timegates)
    or print out all training data. Also need to create switch to print a streaming feature generator ! to do!

  04-05-2018
    publishing tcfg, a version of trendcalculus with options to generate trend specific features, using the -g -n -m options, using rewind and hindsight

Embedded Libraries::

pl.lapp -- part of the Penlight package for Lua.
           Copyright (C) 2009 Steve Donovan, David Manura.
           https://github.com/stevedonovan/Penlight/blob/master/LICENSE.md
           https://github.com/stevedonovan/Penlight

pl.sip  -- part of the Penlight package for Lua.
           Copyright (C) 2009 Steve Donovan, David Manura.
           https://github.com/stevedonovan/Penlight/blob/master/LICENSE.md
           https://github.com/stevedonovan/Penlight

csv-1.1 -- the csv parsing library for lua.
           Copyright (c) 2013-2014 Incremental IP Limited
           Copyright (c) 2014 Kevin Martin
           https://github.com/geoffleyland/lua-csv/blob/master/LICENSE
           https://github.com/geoffleyland/lua-csv

date    -- Date and Time string parsing; Time addition and subtraction; Time span calculation; Supports ISO 8601 Dates.
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
                


  TrendCalculus: Streaming Multi-Scale Trend Change Detection Algorithm
  tcfg: TrendCalculus Feature Generator

  Copyright 2014-2018, ByteSumo Limited (Andrew J Morgan)

  Author:  Andrew J Morgan
  Version: 1.0.0
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


  Usage:  
        > cat db_output.csv | luajit trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n 5 -r \
	  | tee reversals1.csv | luajit trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n 2 -r \
          | tee reversals2.csv | luajit trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n 2 -r \
	
	  | tee reversals3.csv | luajit trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n 2 -r > reversals4.csv
	> lua trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n 5 -r -f db_output.csv

  Options:
      -v --version                       Show version and help
      -n (default 5)                     Number of observations (window size)
      -m (default n)			 Additional timeframes for genfeatures output
      -F (string default ",")            input record delimeter
      -OFS (string default ",")          output record delimeter
      -h --header                        indicates there is a column header row
      -s --splits                        splits complex bars
      -r --reversals                     output reversals only, must be used with -s option
      -p --pass                          user value, to set "pass" val over the data, use with -r option
      -f <file> (default stdin)          input file to process, can default to pick up STDIN if unset.
      -g --genfeatures                   generate trend features and relative targets adjacent to each other
      -b (default 5)                     only generate features for 5 steps before/after a reversal to balance features around turning points
      notes: 
        (1)
            on a mac commandline, to set OFS to tab delimited
            you need to use OFS = "ctrl-v<tab>" to get round tab expansion on the cli
        (2) 
            To accept stdin streams, do not set the filename, the defaults will kick in.
        (3)
            Data Input Format:
            -- delimited data, ie csv. Enclosing quotes discouraged.
            -- set your delimeters using AWK-like syntax, using -F and/or -OFS
            -- this program will accept data any column width, but only use needed named columns
            -- please use a header row with Columns named in line with the following formats:
            
            _Columns_               _Column_Aliases_Accepted_
            1: TimeSeriesIdentifier ("ric", "id", "ref", "instrument", "ts", "ticker", "TimeSeriesIdentifier", "1")
            2: ObservationTime      ("date", "time", "timestamp", "period", "datetime","date_time", "2")      
            3: Value                ("last", "close", "value", "obs", "count", "sum", "price", "measurement", "3")
 
        -- if your data is in this format, but has different headers, the program will need alteration to accept your column alias.

        References:
        https://bitbucket.org/bytesumo/trendcalculus-public
        https://github.com/geoffleyland/lua-csv
        https://github.com/stevedonovan/Penlight

---------------------------------------------------------------------------------
     
]]


                  -- Libraries --
 pcall(require, "strict")

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Start of External Dependent code block. csv and pl.lapp XXXXXXXXXXXXXXXXXXXXXXXXXX 
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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




--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX This is the end of inline embedded code. Now for Trendcalculus Code XXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- require the embedded functions above:

-- require pl.lapp that parses command line options very nicely.
local lapp = require 'pl.lapp'

-- lapp.slack allows for multichar commandline options
lapp.slack = true

local csv = require 'csv'
  -- Note csv is a csv parser that loads files in buffered chunks (not in memory in one go) allowing it to work on Streams... not just large batches.
  -- Note the lua-csv code comes via GeoffLeyland on github. Great code, thank you!

  -- configure the Lapp Framework options parser

local args = lapp [[
  Options
   -v                                 Show version and help
   -n (default 5)                     trend window timeframe
   -m (default 5)		      additional features timewindow, incremented over and above the trend window timeframe,n. Use with -g switch.
   -F (string default ",")            input record delimeter
   -OFS (string default ",")          the output record delimeter
   -h --header                        indicates there is a column header row on input
   -H --outheader                     indicate if you want an output header record
   -f (string default "<stdin>")      input file to process
   -s --split                         print split data        
   -r --reversals                     outputs reversal data, must be used with -s option  (note: bardates not calculated properly)
   -p (default 1)                     passthrough of user values, used to  the pass number of the algo over the data
   -g --genfeatures                   generate trend features and relative targets adjacent to each other
   -b --balanced		      only generate features for 5 steps after a reversal to reduce training to be balanced around turning points
]]

--------------------------------------------------------------------------------------------      
--------------------------------- Initialise and do Admin ---------------------------------- 

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


-- force command line options to simplify usage
if args.r == true and args.s == false then
   args.s = true
end
if args.g == true then
  args.r = true
  args.s = true
end
   if args.m == false then
      args.m = args.n + 1
   else args.m = args.m + 1
   end




-- set out the FileHeaders I accept from the commandline, and remap ones that come in wrong to match our code.
--                                    IF YOU HAVE OTHER COLUMN ALIASES, REMAP THE COLUMN NAMES HERE

params.columns = {   ric  = { names = {"ric", "symbol","ts_id", "id", "ref", "instrument", "ts", "ticker", "TimeSeriesIdentifier", "1"}}
                   , date = { names = {"", "date", "time", "timestamp", "period", "datetime","date_time", "2"}}
                   , last = { names = {"last", "close", "value", "obs", "count", "sum", "price", "measurement", "measure", "3"}}
                 }

--- start to prep the file I want to convert

local data = assert(csv.use(args.f, params))
-- this command hooks up the csv processing "pipeline" configurations through the buffers to the file handle. This is a mapping to input. No data moving yet.
-- there are options I have not set here to optimise the buffer chunk size etc
-- current the buffer size is 1024 * 1024, but I think I will reduce this to cut out latency later. A thing to do when I get time.

local f = assert(csv.openstring(data, data.parameters))
-- the above command then maps the csv buffer pipeline to the openstring parsing code, and awaits a stream input. No data moving yet.

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
      local data = f:read("*a")
      f:close()


--------------------------------------------------------------------------------------------      
----------------------------- Your Function Definitions Go Here ----------------------------      
      -- UPDATE FHLS BARS
      -- here is my udpate function for a fhls record, when you add a new data point to it
      local function update_bar(win, currdate, prevopendate, value, f, h, l, s, hd, ld, fd, sd)
        local opendate = prevopendate -- this traces the opening date using a carry forward approach
        local closedate = currdate
        local first = f
        local high = h
        local low = l
        local second = s
        local highdate = hd
        local lowdate = ld
        local window = win + 1
        local firstdate = fd
        local seconddate = sd
        if value + 0.0000 > h + 0.0000  then    -- find a new high, notice the addition, to force the data type
           high = value
           highdate = currdate
           second = value     -- the latest obs always is later than anything in fhls, so it must be second
           first = low
           firstdate = lowdate
           seconddate = currdate
        elseif value + 0.0000 < l + 0.0000 then -- find a new low, notice the addition, to force the data type
           low = value
           lowdate = currdate     
           second = value     -- the lastest obs is always later than anything in fhls, so it must be second
           first = high
           firstdate = highdate
           seconddate = currdate
        end
        return window, opendate, closedate, first, high, low, second, highdate, lowdate, firstdate, seconddate
      end
      
      -- here is a sign function, it's not in standard lua!
      local function sign(x)
          return x + 0 > 0 and 1 or x + 0 < 0 and -1 or 0
      end
      
      local function previous_offsets(offset, timeframe)
          return offset - timeframe, offset - timeframe*2
      end
      
      local function split_bar(f,   h,  l,  s,  hd,  ld,  fd, sd,
                               pf, ph, pl, ps, phd, pld, pfd, psd)
         local split = {}
         --if sign(sign(h - ph) + sign(l - pl)) == 0 then
            split.f = ps      -- the first is set the second of the previous bar
            split.fd = psd    -- the first date is set to the date of the second on the previous bar
            split.s = f       -- the second is set to the first of the current bar
            split.sd = fd     -- the second date is set to the date of the first on the current bar
                if split.f + 0.00 > split.s + 0.00 then  -- we need to re-establish a high or low now we have two new inputs, first and second.
                    split.h   = split.f
                    split.hd  = split.fd
                    split.l   = split.s
                    split.ld  = split.sd
                else
                    split.h   = split.s
                    split.hd  = split.sd
                    split.l   = split.f
                    split.ld  = split.fd
                end
         --end
      return split
      end
      
       local function sigmoid(x)
          -- if sigmoid_daily_change = 1/(1+ math.exp(-1*daily_per_change))
          if x >= 0 then
             local z = math.exp(-1*x)
             return 1 / (1 + z)
         else
             local z = math.exp(-1*x) -- was minus     1/(1+exp(-x))
             return (1 / (1 + z))
         end
       end 

      local function rollingtrend(current, phigh, plow)
        local mid  = 0.0000 + ((phigh + plow) * 0.5)
        local trend = sign(sign(current - phigh + 0.0000) + sign(current - plow + 0.0000))
        local sentiment = sign(0.0000 + current - mid)  
        -- local tzscore = (1 +((trend + sentiment) * 0.5)) * 0.5
 
        -- I will test using a normalised score, where the min/max vals are the phigh and plow
	local hez, lez = 0,0
        if (phigh - plow + 0.0000) < 0.0000001 then 
            tzscore = 0.0000
        else 
            --tzscore = sigmoid((0.0000 + current - plow) / (phigh - plow + 0.0000))  -- before I used the percent change from previous mid
            tzscore = tonumber(string.format("%.10f", sigmoid((( mid - current) / mid) *100 ))) -- *100  - calculate the percent change from mid, via sigmoid 
	    hez = tonumber(string.format("%.10f", sigmoid((( phigh - current) / phigh) *100 )))
            lez = tonumber(string.format("%.10f", sigmoid((( plow - current) / plow) *100 )))
        end 
        return trend, sentiment, tzscore, hez, lez
      end

      local function relativechange(current, curr_offset, target, target_offset)
        local countdown = target_offset - curr_offset
        local percentchange = (target - current) / current
        return countdown, percentchange
      end



      local function hindsight(ric, roff, offset, rcurrent, rdate, trend)
        local hist = math.floor(args.n / 4)
        local counter = 0
        local map = " "
        local trendcat = "U"
        local ignore, daily_per_change, countdown, per_change, signed_countdown = 0, 0, 0, 0, 0
        local first, second, fdays, sdays = 0 -- print first and second of the rolling values for this.
        local max_first, max_second, max_fday, max_sdays = 0
        
      
        
        for i = revhist[roff].revoffset, (offset - 1) do -- start of the offset range loop
          counter = counter + 1
          
          -- calculate the relative change from the offset i's price and offset to the target price and offset
          -- if counter > 1 then
            countdown, per_change = relativechange(fhls[i][1].f, i, rcurrent, offset)
          -- end
          
          if i > maxwindow then --args.n then
          -- on the timeframe of interest, include the rolling price channel pivots, converted into countdowns_from and relative_prices
          --                                firstval            firstoffset        now_price      now_offset
              fdays, first = relativechange(fhls[i][args.n].f,   fhls[i][args.n].fd, fhls[i][1].f,      i )     
              sdays, second = relativechange(fhls[i][args.n].s,   fhls[i][args.n].sd, fhls[i][1].f,      i )  
              
              max_fdays, max_first = relativechange(fhls[i][maxwindow].f,   fhls[i][maxwindow].fd, fhls[i][1].f,      i )     
              max_sdays, max_second = relativechange(fhls[i][maxwindow].s,   fhls[i][maxwindow].sd, fhls[i][1].f,      i )                

          end
          
          if i > 1 then -- is the offset greater than 1, meaning greater than the first ever record?
              ignore, daily_per_change = relativechange(fhls[i-1][1].f, i-1, fhls[i][1].f, i)
          else -- this is the first record this function ever processed, print headers:
              local trendmapheader = "ts_id"
              
              -- I need to calculate elsewhere the size of the final trendmap and call it in as a global, or in the function params.
              for j = 1, (args.n + args.m) -1  do
                trendmapheader = trendmapheader .. args.OFS .. "T" ..  j  
              end
   
              for j = 1, (args.n + args.m) -1  do
                trendmapheader = trendmapheader .. args.OFS .. "E" ..  j
              end
 
	       for j = 1, (args.n + args.m) -1  do
                  trendmapheader = trendmapheader .. args.OFS .. "H" ..  j
               end
              
               for j = 1, (args.n + args.m) -1  do
                  trendmapheader = trendmapheader .. args.OFS .. "L" ..  j
               end

              if args.g == true then
              print( "UserDate"             .. args.OFS ..        -- print date of offset. 
                     -- "ric"              .. args.OFS ..         -- print the timeseries id
                     -- "Offset"           .. args.OFS ..         -- print the offset of that date
                     "Value"         .. args.OFS ..        	  -- print Value of the timeseries 
                     -- "unit_per_change"  .. args.OFS ..         -- the daily relative change since yesterday
                     -- "Value"            .. args.OFS ..         -- print the price on that offset
                     -- "fdays"              .. args.OFS ..       -- print the timespan since first on args.n
                     -- "first"              .. args.OFS ..       -- print the % change since first
                     -- "sdays"              .. args.OFS ..       -- print the timespan since second on args.n
                     -- "second"             .. args.OFS ..       -- print the % change since second 
                    
                     -- "mxfdays"              .. args.OFS ..     -- print the timespan since first on args.n
                     -- "mxfirst"              .. args.OFS ..     -- print the % change since first
                     -- "mxsdays"              .. args.OFS ..     -- print the timespan since second on args.n
                     -- "mxsecond"             .. args.OFS ..     -- print the % change since second 
   
                    -- "trend"                 .. args.OFS ..     -- print the real trend, the one used to find reversals
               
                    --"target_countdown"         .. args.OFS ..     -- print the offset countdown until the reversal
                    --"target_per_change"      .. args.OFS ..     -- print the percent change from this offset price to the target reversal price
                    trendmapheader             .. args.OFS ..     -- print the trendmap for this offset, saved by alltz on tf =1 in fhls.z
		    "s"                       			  -- print the real trend, the one used to find reversals
                   ) 
              end
          end
          -- here I'm adding in some feature modifiers to help in the deep learning. 
          --   (1) try out "signed countdowns" so I can predict the time to reversals AND the direction of the trend in one go.
          --   (2) modify the countdown, to clip it down to 6=Rising, +5,+4,+3,+2,+1,0,-1,-2,-3,-4,-5,-6=Falling
          
          -- clipping rule: 
          -- if countdown > 6 then
          --   countdown = 6
          -- end
          -- signing rule:

          if countdown > 0 then
            signed_countdown = countdown * trend 
          end
          
          if trend == 1 then
             trendcat = "U"
          else
             trendcat ="D"
          end

          if offset > maxwindow then
            
            -- fetch in all the trendmaps over the history window and cat the batches together
            map = ric            -- fhls[i][1].z -- this is the null dummy record, set it to zero --- this is now holding the timeseries id
           
            -- I have stored the whole trendmap in .z earlier 
            -- for h = 1, hist -1 do
            --   map = map .. fhls[i - h][1].z 
            -- end

	    map = map .. fhls[i][1].z  
            local _, maplen = string.gsub(map, ",", "")
	    -- local maplen = string.len(map)

	    -- add in the Ez features
	    map = map .. fhls[i][1].ez
            
            -- add in the Hez and Lez features too
            map = map .. fhls[i][1].hez
            map = map .. fhls[i][1].lez

          if (counter < 3 or countdown < 3 or args.b == false) and maplen > (args.n + args.m -2)  and args.g == true then -- +2 
              print(fhls[i][1].ut            .. args.OFS ..     -- print the date on that offset
                    -- ric             .. args.OFS ..     -- print the timeseries id
                    -- fhls[i][1].od   .. args.OFS ..     -- print the offset of that date
                    fhls[i][1].f   	.. args.OFS ..     -- print the price of the record
                    -- daily_per_change .. args.OFS ..    -- the daily relative change since yesterday
                    -- fhls[i][1].f    .. args.OFS ..     -- print the price on that offset 
                    -- fhls[i][1].od   .. args.OFS ..     -- print the offset of that date
                    -- fdays              .. args.OFS ..     -- print the timespan since first on args.n
                    -- first              .. args.OFS ..     -- print the % change since first
                    -- sdays              .. args.OFS ..     -- print the timespan since second on args.n
                    -- second             .. args.OFS ..     -- print the % change since second 
                    
                    -- max_fdays              .. args.OFS ..     -- print the timespan since first on args.n
                    -- max_first              .. args.OFS ..     -- print the % change since first
                    -- max_sdays              .. args.OFS ..     -- print the timespan since second on args.n
                    -- max_second             .. args.OFS ..     -- print the % change since second 
                    
                    -- trendcat        .. args.OFS ..    -- the target trend to guess
                    -- countdown  .. args.OFS ..     -- print the offset countdown until the reversal
                    --per_change      .. args.OFS ..     -- print the percent change from this offset price to the target reversal price
                    map               .. args.OFS ..     -- print the trend map features 
		    trend           			 -- the target trend to guess
                   ) 
	  end -- end of: if countdown < 6 then	
          end
          -- fhls[i][1].countdown = countdown
          -- fhls[i][1].per_change = per_change
          fhls[i - maxwindow - 1] = nil 
        end -- end of the offset range loop 
	
      end -- end of function


      
--------------------------------------------------------------------------------------------      
--------------------------- FILE PROCESSING COMMANDS GO HERE -------------------------------

      -- now the data should be all queued up to convert. We access the data input using 
      -- the returned objects's method: "lines"
      -- to run this code, pass the local "f" or whatever you called your input stream, as the param to the method parse  
  
        --- here is the function call that starts to iterate over the parsed CSV      
        local function parse(streamhandle)
        
          --{BEGIN -- define the things to do before the file read starts here. Like Awk BEGIN
        
               offset = 0   -- track the row numbers as an offset from the file start
                            -- Note the first data point row is offset = 1
               fhls = {}    -- create the map of FHLS data
               trend ={}    -- create a map of trend data
               maxwindow = assert(args.n + args.m ) -- default is 20, or set by user --- on n = 25, results in 400 timeframes
               prev = {}
               revhist = {} -- create a global map for reversal history
               roff = 1
               
               -- print out the headers for the output, if these are asked for. 
                 if args.H == true then
                 
                          if args.s == false and args.r == false and args.g == false then
                                 print(  "ts_id" .. args.OFS ..      -- this is the timeseries id
                                         "opendate" .. args.OFS ..          -- bar open date
                                         "closedate" .. args.OFS ..         -- bar close date
                                         "offset" .. args.OFS ..            -- closing offset
                                         "timeframe"  .. args.OFS  ..       -- this is the time frame
                                         "measure" .. args.OFS ..           -- this is the price or value studied
                                         "first" .. args.OFS ..             -- first
                                         "high" .. args.OFS ..              -- high
                                         "low" .. args.OFS ..               -- low
                                         "second" .. args.OFS ..            -- second
                                         "high_date" .. args.OFS ..         -- high date
                                         "low_date"   .. args.OFS ..        -- low date
                                         "first_date" .. args.OFS ..        -- first date
                                         "second_date"                      -- second date
                                  )
                           elseif args.s == true and args.r == false and args.g == false then 
                                 print(  "ts_id" .. args.OFS ..      -- this is the timeseries id
                                         "opendate" .. args.OFS ..          -- bar open date
                                         "closedate"  .. args.OFS ..        -- bar close date
                                          -- "offsetdate" .. args.OFS ..        -- the offset's date
                                         "offset" .. args.OFS ..            -- closing offset
                                         "split"  .. args.OFS ..            -- this will record if the bar is a split one or not
                                         "timeframe"  .. args.OFS  ..       -- this is the time frame
                                         "measure" .. args.OFS ..           -- this is the price or value studied
                                         "first" .. args.OFS ..             -- first
                                         "high" .. args.OFS ..              -- high
                                         "low" .. args.OFS ..               -- low
                                         "second" .. args.OFS ..            -- second
                                         "high_date" .. args.OFS ..         -- high date
                                         "low_date"  .. args.OFS ..         -- low date
                                         "first_date" .. args.OFS ..        -- first date
                                         "second_date"  .. args.OFS ..    -- second date
                                         "trend"
                                  )
                           elseif args.r == true  and args.g == false then
                                print(
                                  "ts_id"        .. args.OFS ..           -- this is the timeseries id
				  "offset"	 .. args.OFS ..		  -- offset
                                  "date"         .. args.OFS ..           -- bar open date
                                  "value"        .. args.OFS ..           -- bar open date   ric,date,price,info,pass,start_date,start_price
                                  "info"         .. args.OFS ..           -- the timeframe
                                  "pass"         -- .. args.OFS ..        -- the pass number for multipass
                                  -- "bardate"   -- the date of the FHLS "bar" you can join back to for graphing purposes.                   
                                )
                         --[[  elseif args.g == true then
                             -- THE GENERATED FEATURES AND TARGETS
                             print (
                               "ts_id"          .. args.OFS ..
                               "date"           .. args.OFS ..
                               "value"          .. args.OFS ..
                               "targets"        .. args.OFS ..
                               "trendfeatures"  
                               )
			  --]]
                           end
                 end            
    
    
          --}{BODY - loop through the data stream.
          
               for r in streamhandle:lines() do            
                 offset = offset + 1
                 -- on start up, we have 
                 frame = math.min(maxwindow, offset) -- set the frame as the smallest of maxwindow, or the row count.

                     -- GLOBAL ASSOCIATIVE ARRAYS
                     -- fhls[offset] = {} -- create an initial table for fhls summaries.
                     -- for this offset record, generate a FHLS bar having a timeframe of only 1 observation (this one)
                 fhls[offset] = {}  
                 trend[offset] = {}

                 -- rather than do complex stuff to calculate offsets, easy to just rotate the values here on mod of N
                 if offset % args.n == 0 then     -- we fire reversal finding on widows of n inputs. A modulus of the offset is the trigger of a new window.
                      off, poff = offset, off     -- we set the window offset "off" as current offset, previous offset "poff" as current "off"
                 end  
                 
                -- configure the first fhls[offset][tf] FHLS record (tf = 1) for each obs, stack up the rest to maxwindow size      
                -- note we set this for each arriving observation. 
                -- for every single value we see, run these:
                -- set the first timeframe, 1, for this offset manually, setting them as observed values.
		-- FIXED -- I changed the dates to all be offsets, and added in a user-time field "ut" for tf = 1, z = the trendmap,
                --  avg_z is the average over the trend map.

                fhls[offset][1] = {ut=r.date, d=offset, od = offset, cd = offset, f = r.last, h = r.last, l = r.last, s = r.last, 
                                   hd = offset, ld = offset, fd = offset, sd =offset, z = "", ez = "", hez = "", lez = "",  avg_z = 0}

                trend[offset][1] = {lasttrend = 0, lastod = r.date}
                    
                -- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                -- end of first item of the timeframe stack processing, now start triangular build
                -- incremenatlly generate the FHLS data for all other timeframes having history, so offset > 1              
                 
                if offset == 1 then
                    revhist[roff] = { rdate = r.date, rprice = r.last, rinfo = "F", revoffset = 1}
		    -- note that roff = 1 at this point in the flow
                end 

                -- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                -- end of first item of the timeframe stack processing, now start triangular build
                -- incremenatlly generate the FHLS data for all other timeframes having history, so offset > 1                     
                 
                 if offset > 1 then            
                    rt = ""
                    local sum_rt = 0
                    local prev ={}             
                    local running_total = 0
  
                    -- this is a critical loop, counting up to the frame (N or as high as possible) for each time step
                    -- local alltz = "#"
		    
                    for t = 1, (frame -1 ) do ---- FIXME should frame be frame, or (frame -1) ... as it was originally?   
                      local p = offset - 1  -- the row right behind the leading data edge     
                                  
                      local tf, opendate, closedate, ff, hh, ll, ss, hhd, lld, ffd, ssd = update_bar(t, offset, fhls[p][t].od, r.last, fhls[p][t].f, fhls[p][t].h, fhls[p][t].l, fhls[p][t].s, fhls[p][t].hd, fhls[p][t].ld, fhls[p][t].fd, fhls[p][t].sd)  

                      local tt, yt, tz, ez, hz, lz = nil,nil,nil,nil,"",""
                      
                      if offset > t*2 + 1 then --- add in the rolling trend calculations here on each offset with history, for each timeframe
                          tt, yt, tz, hz, lz  = rollingtrend(r.last, fhls[p - t][t].h, fhls[p - t][t].l) 
		      else
                          tt, yt, tz, hz, lz = 0,0,0,0,0
		      end 
		      -- print(hz .. "," .. lz)
			-- now I have tz (relative postition of cur price against previous bar)
			-- I need to calculate a running average up the timeframes to calc Ez easily, and stash that into .z for printing
			-- this still needs doing. must also stop printing old data from last timesteps
			-- and most also let user choose numbers of features to produce ... way more helpful now I'm a user...


                      -- alltz = alltz .. args.OFS .. tz  -- replaced this with the line below, to increment the map in the .z field of offset[1]

                      fhls[offset][tf] = {d = offset, od = opendate, cd = closedate, f = ff, h = hh, l = ll, s = ss, hd = hhd, ld = lld, fd = ffd, sd = ssd, z = tz, hez = hz, lez = lz}

                      -- reduce columns in trendmap

                      running_total = running_total + tz
                       h_running_total = running_total + hz
                       l_running_total = running_total + lz
		      ez = running_total / tf		
                      local ahz =  h_running_total / tf
                      local alz =  l_running_total / tf       

		      -- here I save the data to tz, ez, lez, hez
                      if  tf < (args.n + args.m + 4) then  --tf < args.n + 1 or tf%5 == 0 then -- includes trend for timeframes up to n+m
                          fhls[offset][1].z = fhls[offset][1].z  .. args.OFS .. tz  -- the trendmap is saved on tf =1 for each offset so it is easily retrieved on rewind
                          fhls[offset][1].ez = fhls[offset][1].ez  .. args.OFS .. ez
			  fhls[offset][1].lez = fhls[offset][1].lez  .. args.OFS .. alz
			  fhls[offset][1].hez = fhls[offset][1].hez  .. args.OFS .. ahz
                      end


                      -- this loop fires each n steps, on a timeframe of n
                            if tf == (args.n) and offset%(args.n) == 0 then                                     
                               -- r.date records the date of the Last obs in a timewindow, but our FHLS output pegs the row to the START. Retrieve it here:
                               -- bar_date = fhls[offset - args.n][1].d  
                               
                               if offset / args.n > 1 then
                                   -- prev = fhls[offset - args.n][tf] -- set prev as prev bar values
                                   -- (i set this the long way to be clear what's in the prev record)
                                   prev = {  ut = fhls[offset - args.n][tf].ut
                                           ,  d = fhls[offset - args.n][tf].d
                                           , od = fhls[offset - args.n][tf].od
                                           , cd = fhls[offset - args.n][tf].cd
                                           , f = fhls[offset - args.n][tf].f
                                           , h = fhls[offset - args.n][tf].h
                                           , l = fhls[offset - args.n][tf].l
                                           , s = fhls[offset - args.n][tf].s
                                           , hd = fhls[offset - args.n][tf].hd
                                           , ld = fhls[offset - args.n][tf].ld 
                                           , fd = fhls[offset - args.n][tf].fd 
                                           , sd = fhls[offset - args.n][tf].sd
                                           }
                               else 
                                   prev = fhls[offset][1]    
                               end
                               
                               if args.s == false then -- is this the special splitbar output? no
                               -- no, so print standard output
                                      if args.r == false and args.g == false then
                                        print(      -- this is the rowid of the input file, the offset
                                               r.ric  .. args.OFS ..      -- this is the timeseries id
                                               		-- opendate .. args.OFS ..    -- bar open date
                                               fhls[opendate][1].ut .. args.OFS ..
                                               		-- closedate .. args.OFS ..   -- bar close date
                                               fhls[closedate][1].ut .. args.OFS ..
                                               		-- r.date .. args.OFS ..      -- offset date of publish/close
                                               offset .. args.OFS ..      -- offset of the close
                                               tf .. args.OFS  ..         -- this is the time frame
                                               r.last .. args.OFS ..      -- the closing price/value
                                               ff .. args.OFS ..          -- first of high or low
                                               hh .. args.OFS ..          -- high 
                                               ll .. args.OFS ..          -- low
                                               ss .. args.OFS ..          -- second of high or low
                                               --hhd .. args.OFS ..         -- high date
                                               fhls[hhd][1].ut .. args.OFS ..
                                               --lld -- .. args.OFS ..         -- low date
                                               fhls[lld][1].ut  .. args.OFS ..
                                               -- ffd .. args.OFS ..         -- first date
                                               fhls[ffd][1].ut  .. args.OFS ..
                                               -- ssd                        -- second date  
                                               fhls[ssd][1].ut  
                                              )
                                      end
                               else     -- else, yes, user asked for a special splitbar print output, produce FHLS with Splitbars

                                      local hdiff = sign(hh - prev.h)
                                      local ldiff = sign(ll - prev.l)

                                      -- before we calculate all the splitbar stuff, cache the trend and opendate of the unsplit bar
                                      local strend = sign(hdiff + ldiff)
                                      trend[offset][tf] = {lasttrend = strend}

                                      if strend == 0 then -- (hh ~= prev.h and ll ~= prev.l) then
                                        -- if this is a special bar viewed against the previous one, then
                                        -- print the split bar that includes some of the previous bar inputs
                                        -- (I need to include the output of the function written in my notebook here... calcsplitbar(prev, curr)

                                        -- create a container for the new splitbar
                                        local splitbar = {}
 
                                        -- populate it with the new splitbar details we create with the function                                       
                                        splitbar = split_bar(ff, hh, ll, ss, hhd, lld, ffd, ssd, prev.f, prev.h, prev.l, prev.s, prev.hd, prev.ld, prev.fd, prev.sd) 
                                        
                                        local splittrend = sign(sign(splitbar.h - prev.h)+sign(splitbar.l - prev.l))
                                        
                                        -- if the splitbar's trend happens to also have a zero value, do a last obs carried forward, setting it to the previous trend.
                                        if splittrend == 0 then
                                          splittrend = trend[poff][tf].lasttrend 
                                        end
                                        
                                        -- now overwrite the cached trend with the curr split one
                                        trend[offset][tf] = {lasttrend = splittrend}
                                        
                                        if args.r == false and args.g == false then
                                                -- print the splitbar just before printing the normal bar
                                                print(                        -- this is the rowid of the input file, the offset
                                                 r.ric  .. args.OFS ..        -- this is the timeseries id                                         
                                                	 --splitbar.fd .. args.OFS ..         -- bar open date (is the splitbar's first date)
                                                 fhls[splitbar.fd][1].ut .. args.OFS ..  -- bar open date (is the splitbar's first date)
                                                	 -- splitbar.sd .. args.OFS ..         -- bar close date (is the splitbar's second date)
                                                 fhls[splitbar.sd][1].ut .. args.OFS .. -- bar close date (is the splitbar's second date)
                                                 	-- r.date .. args.OFS ..        -- offset's date of publish                                         
                                                 offset .. args.OFS ..        -- the offset
                                                 "0"    .. args.OFS ..        -- a one says this is a split bar
                                                 tf .. args.OFS  ..           -- this is the time frame
                                                 r.last .. args.OFS ..              -- closing price / value
                                                 splitbar.f .. args.OFS ..          -- first
                                                 splitbar.h .. args.OFS ..          -- high
                                                 splitbar.l .. args.OFS ..          -- low
                                                 splitbar.s .. args.OFS ..          -- second
                                                 splitbar.hd .. args.OFS ..         -- high date
                                                 splitbar.ld .. args.OFS ..         -- low date
                                                 splitbar.fd .. args.OFS ..         -- first date
                                                 splitbar.sd                        -- second date
                                                 .. args.OFS .. splittrend                         -- simple trend (split to prev)                                              
                                                )
                                        end              
                                      
                                       -- now we've print the splitbar, potentially print a reversal on prev bar before the split bar
                                        if args.r == true and poff ~= nil then
                                           if splittrend == trend[poff][tf].lasttrend * -1 then
                                              -- we must print the reversal found when comparing the complex bar to the splitbar
                                              if trend[poff][tf].lasttrend == 1 then  -- the split bar is the high
                                                  if args.g == false then
                                                  print(
                                                         r.ric        .. args.OFS ..        -- this  is the timeseries id     
                                                         prev.hd      .. args.OFS ..        -- high date's offset
							                                           fhls[prev.hd][1].ut .. args.OFS ..  -- high date 
                                                         prev.h       .. args.OFS ..        -- high
                                                         "Top"        .. args.OFS ..        -- this is the time frame
                                                         args.p       --.. args.OFS ..        -- user pass id
                                                         -- prev.od                         -- the bar open date is the "bar date"
                                                        )
						  end
                                                        -- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Here is where we do the hindsight call XXXXXXXXXXXXXXX
						  if args.g == true then 
					              hindsight(r.ric, roff, prev.hd, prev.h, fhls[prev.hd][1].ut, 1)
                                                  end
                                                        -- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Here is where we do the hindsight call XXXXXXXXXXXXXXX
                                                  roff = roff + 1
                                                  revhist[roff] = {revoffset = prev.hd}
                                              elseif trend[poff][tf].lasttrend == -1 then
                                                  if args.g == false then
                                                  print(
                                                         r.ric        .. args.OFS ..        -- this is the timeseries id     
                                                         prev.ld      .. args.OFS ..        -- low date's offset
                                                         fhls[prev.ld][1].ut .. args.OFS ..  -- low date
                                                         prev.l       .. args.OFS ..        -- low
                                                         "Bottom"     .. args.OFS ..        -- this is the time frame
                                                         args.p       -- .. args.OFS ..        -- user pass id
                                                         --prev.od                          -- the bar open date is the "bar date"
                                                        )
                                                  end
                                                  hindsight(r.ric, roff, prev.ld, prev.l, fhls[prev.ld][1].ut, -1)
                                                  roff = roff + 1
                                                  revhist[roff] = {revoffset = prev.ld}
                                              end
                                           end
                                        end 
                                      
                                      

                                        local complextrend = sign(sign(hh - splitbar.h) + sign(ll - splitbar.l))
                                        
                                        if complextrend == 0 then
                                          complextrend = splittrend
                                        end
                                        
                                        trend[offset][tf] = {lasttrend = complextrend} -- this overwrites the simple 0 assignment made earlier
                                        
                                        if args.r == false and args.g == false then                                      
                                              -- here we print out the inner or outer bar aggregate bar with strend based on this to the split bar 
                                              print(                           -- this is the rowid of the input file, the offset
                                                 r.ric  .. args.OFS ..         -- this is the timeseries id
                                                 	-- splitbar.sd     .. args.OFS ..         -- bar open date, shifted to the split bar's second date (of final high / low)
						 fhls[splitbar.sd][1].ut .. args.OFS ..    -- 
                                                 	-- r.date .. args.OFS ..         -- bar close date
                                                 fhls[splitbar.sd][1].ut .. args.OFS ..    --
                                                 	-- r.date .. args.OFS ..         -- the offset publish date
                                                 offset .. args.OFS ..         -- the closing offset of this printout
                                                 "1"    .. args.OFS ..         -- a one = splitbar, a 0 is a normal bar
                                                 tf     .. args.OFS  ..        -- this is the time frame
                                                 r.last .. args.OFS ..         -- raw measure (last value of period)
                                                 ff     .. args.OFS ..         -- first
                                                 hh     .. args.OFS ..         -- high
                                                 ll     .. args.OFS ..         -- low
                                                 ss     .. args.OFS ..         -- second
                                                 hhd    .. args.OFS ..         -- high date
                                                 lld    .. args.OFS ..         -- low date
                                                 ffd    .. args.OFS ..         -- first date
                                                 ssd                           -- second date  
                                                 .. args.OFS .. complextrend                                         
                                                )
                                         end
                                              
                                        -- now we've print the complex bar, print the reversal found on the split bar before it       
                                        if args.r == true  then
                                           if complextrend == splittrend * -1 then
                                              -- we must print the reversal found when comparing the complex bar to the splitbar
                                              if splittrend == 1 then  -- the split bar is the high
                                                  if args.g == false then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this  is the timeseries id     
                                                         splitbar.hd      .. args.OFS ..        -- high date's offset
                                                         fhls[splitbar.hd][1].ut .. args.OFS ..  -- high date
                                                         splitbar.h       .. args.OFS ..        -- high
                                                         "Top"            .. args.OFS ..        -- this is the time frame
                                                         args.p       --    .. args.OFS ..        -- user pass id
                                                         --prev.sd                            -- the bar open date is the "bar date"
                                                        )
                                                  end
                                                  hindsight(r.ric, roff, splitbar.hd, splitbar.h, fhls[splitbar.hd][1].ut, 1)
                                                  roff = roff + 1
                                                  revhist[roff] = {revoffset = splitbar.hd}
                                              elseif splittrend == -1 then
                                                  if args.g == false then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         splitbar.ld      .. args.OFS ..        -- low date's offset
                                                         fhls[splitbar.ld][1].ut .. args.OFS ..  -- low date
                                                         splitbar.l       .. args.OFS ..        -- low
                                                         "Bottom"         .. args.OFS ..        -- this is the time frame
                                                         args.p           --.. args.OFS ..        -- user pass id
                                                         --prev.sd                            -- the bar open date is the "bar date"
                                                        )
                                                  end
                                                  hindsight(r.ric, roff, splitbar.ld, splitbar.l, fhls[splitbar.ld][1].ut, -1)
						                                      roff = roff + 1
						                                      revhist[roff] = {revoffset = splitbar.ld}
                                              end
                                           end
                                        end 

                                      else -- this is a simple bar, so print a simple -s shaped bar
                                                                              
                                      -- here we print out the normal aggregate bar.  
                                      trend[offset][tf] = {lasttrend = strend} 
                                      if args.r == false and args.g == false then
                                            print(      -- this is the rowid of the input file, the offset
                                               r.ric  .. args.OFS ..         -- this is the timeseries id
                                               		-- opendate .. args.OFS ..       -- the bar open date
                                               fhls[opendate][1].ut .. args.OFS ..
                                               		-- r.date .. args.OFS ..         -- the closing date of this offset
                                               fhls[closedate][1].ut .. args.OFS ..                                               
                                               		-- r.date .. args.OFS ..         -- the offset date of this offset                                         
                                               offset .. args.OFS ..         -- the offset of this printout
                                               "1"    .. args.OFS ..         -- a one = splitbar, a 0 is a normal bar
                                               tf     .. args.OFS  ..        -- this is the time frame
                                               r.last .. args.OFS ..         -- raw measure (last value of period)
                                               ff     .. args.OFS ..         -- first
                                               hh     .. args.OFS ..         -- high
                                               ll     .. args.OFS ..         -- low
                                               ss     .. args.OFS ..         -- second
                                               hhd    .. args.OFS ..         -- high date
                                               lld    .. args.OFS ..         -- low date
                                               ffd    .. args.OFS ..         -- first date
                                               ssd                            -- second date  
                                               .. args.OFS .. strend                                         
                                              )  
                                        end 
                                        -- now we've print the simple bar, print any reversal found on the prev bar before it                                      
                                        if args.r == true and offset > (2 * args.n + 1) then
                                           local pv = trend[poff][tf]
                                           if strend ~= pv.lasttrend then
                                              -- we must print the reversal found when comparing the complex bar to the splitbar
                                              if pv.lasttrend == 1 then  -- the split bar is the high
                                                  if args.g == false then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         prev.hd          .. args.OFS ..        -- high date's offset
                                                         fhls[prev.hd][1].ut .. args.OFS ..  -- high date
                                                         prev.h           .. args.OFS ..        -- high
                                                         "Top"       .. args.OFS ..        -- this is the time frame
                                                         args.p          --  .. args.OFS ..        -- user pass id
                                                         -- prev.od                            -- the bar open date is the "bar date"
                                                        )
                                                  end
                                                  hindsight(r.ric, roff, prev.hd, prev.h, fhls[prev.hd][1].ut, 1)
                                                  roff = roff + 1
                                                  revhist[roff] = {revoffset = prev.hd}

                                              elseif pv.lasttrend == -1 then -- the prev bar is the low
                                                  if args.g == false then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         prev.ld          .. args.OFS ..        -- low date's offset
                                                         fhls[prev.ld][1].ut .. args.OFS ..  -- high date
                                                         prev.l           .. args.OFS ..        -- low
                                                         "Bottom"    .. args.OFS ..        -- this is the time frame
                                                         args.p          --  .. args.OFS ..        -- user pass id
                                                        --  prev.od                            -- the bar open date is the "bar date"
                                                        )
                                                  end
                                                  hindsight(r.ric, roff, prev.ld, prev.l, fhls[prev.ld][1].ut, -1)
                                                  roff = roff + 1
                                                  revhist[roff] = {revoffset = prev.ld}
                                              end
                                           end
                                        end 
                  
                                      end -- end of: if strend == 0 then
                                end
                             -- to create the splitbars in the future, we save the current values into prev.
                             -- prev = {f = ff, h = hh, l = ll, s = ss, hd = hhd, ld = lld, fd = ffd, sd = ssd} 

                            end -- end of bar boundary
                            
                                        
                      -- END of: this loop fires each n steps, on a timeframe of n     
                    end  -- end of for t = 1, (frame -1) do 
                 end --  end of  if offset > 1 then

           -- FIX ME UP AT THE END
           -- I need to replace this delete function with one that is tied to reversals, say deleting history more than 10 reversals ago.
           --      if offset > args.n*3+1 then 
                  -- delete array older than is needed (say 3 widest bars?), to keep memory consumption low
           --         fhls[offset - args.n*3+1] = nil                           
           --      end
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


