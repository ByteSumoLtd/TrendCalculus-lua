--[[ 

 _______  ______    _______  __    _  ______     _______  _______  ___      _______  __   __  ___      __   __  _______ 
|       ||    _ |  |       ||  |  | ||      |   |       ||   _   ||   |    |       ||  | |  ||   |    |  | |  ||       |
|_     _||   | ||  |    ___||   |_| ||  _    |  |       ||  |_|  ||   |    |       ||  | |  ||   |    |  | |  ||  _____|
  |   |  |   |_||_ |   |___ |       || | |   |  |       ||       ||   |    |       ||  |_|  ||   |    |  |_|  || |_____ 
  |   |  |    __  ||    ___||  _    || |_|   |  |      _||       ||   |___ |      _||       ||   |___ |       ||_____  |
  |   |  |   |  | ||   |___ | | |   ||       |  |     |_ |   _   ||       ||     |_ |       ||       ||       | _____| |
  |___|  |___|  |_||_______||_|  |__||______|   |_______||__| |__||_______||_______||_______||_______||_______||_______|
                                                                                                                        
TrendCalculus: Streaming Multi-Scale Trend Change Detection Algorithm

Copyright 2015 ByteSumo Limited

Author: Andrew J Morgan

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
         
         To do: Fold in lua-csv and pl.lapp functions into the single codebase to create a fat lua file with zero dependencies.
                (this should aid in compilation via luajit, terralang, etc, as well as simplify usage.)
                Tailor the C headers as needed. Test C based compile. Create a makfile.
         
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
                


  TrendCalculus: Trend Change Detection Algorithm 
  Copyright, ByteSumo Ltd., 2014.
  All rights reserved.
  Author: Andrew J Morgan
  Version: 0.2.0
  
  Notes:  No unauthorised use or distribution of this code what so ever.

  Usage:  
          > cat tst.dat | lua fhls.lua -F "," -h
          > lua fhls.lua -F "," -f input.dat
  Options
      -v --version                       Show version and help
      -n (default 5)                     Number of observations (window size)
      -F (string default ",")            input record delimeter
      -OFS (string default ",")          output record delimeter
      -h --header                        indicates there is a column header row
      -s --splits                        splits complex bars
      -r --reversals                     output reversals only, must be used with -s option
      -p --pass                          user value, to set "pass" val over the data, use with -r option
      -f <file> (default stdin)          input file to process, can default to pick up STDIN if unset.

      note: 
        (1)
            on a mac commandline, to set OFS to tab delimited
            you need to use OFS = "ctrl-v<tab>" to get round tab expansion on cli
        (2) 
            To accept stdin streams, do not set the filename, the defaults will kick in.
        (3)
            Data Input Format:
            -- delimited data, ie csv. Enclosing quotes discouraged.
            -- set your delimeters using AWK-like syntax, using -F and/or -OFS
            -- this program will accept data any column width, but only use first three columns
            -- please use a header row with Columns named in line with the following formats:
            
            _Columns_               _Column_Aliases_Accepted_
            1: TimeSeriesIdentifier ("ric", "id", "ref", "instrument", "ts", "ticker", "TimeSeriesIdentifier", "1")
            2: ObservationTime      ("last", "close", "value", "obs", "count", "sum", "price", "measurement", "2")     
            3: Value                ("date", "time", "timestamp", "period", "datetime","date_time", "3")
 
        -- if your data is in this format, but has different headers, the program will need alteration to accept your column alias.

---------------------------------------------------------------------------------
     
]]


                  -- Libraries --
-- pcall(require, "strict")

      -- I was having issues with macports and luarocks. These help:

local csv = require 'csv'

      -- require just the command line part of penlight, to make this parameter driven off the command line more nicely
      -- load pl.pretty and pl.slack as helpers -- this is only needed for trouble shooting    

local lapp = require 'pl.lapp'
-- local pretty = require 'pl.pretty'
lapp.slack = true

  -- load csv, which is a csv parser that loads files in buffered chunks (not in memory in one go) allowing it to work on Streams... not just large batches.
  -- Note the lua-csv code comes via GeoffLeyland on github. Great code, thank you!

  -- configure the Lapp Framework options parser
local args = lapp [[
  Options
   -v                                 Show version and help
   -n (default 5)                     trend window timeframe
   -F (string default ",")            input record delimeter
   -OFS (string default ",")          the output record delimeter
   -h --header                        indicates there is a column header row on input
   -H --outheader                     indicate if you want an output header record
   -f (string default "<stdin>")      input file to process
   -s --split                         print split data        
   -r --reversals                     outputs reversal data, must be used with -s option  (note: bardates not calculated properly)
   -p (default 1)                     passthrough of user values, used to  the pass number of the algo over the data             
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


if args.r == true and args.s == false then
   args.s = true
end


-- set out the FileHeaders I accept from the commandline, and remap ones that come in wrong to match our code.
--                                    IF YOU HAVE OTHER COLUMN ALIASES, REMAP THE COLUMN NAMES HERE

params.columns = {   ric  = { names = {"ric", "ts_id", "id", "ref", "instrument", "ts", "ticker", "TimeSeriesIdentifier", "1"}}
                   , last = { names = {"last", "close", "value", "obs", "count", "sum", "price", "measurement", "2"}}
                   , date = { names = {"date", "time", "timestamp", "period", "datetime","date_time", "3"}}}

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
            split.f = ps 
            split.fd = psd
            split.s = f
            split.sd = fd
                if split.f + 0.00 > split.s + 0.00 then
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
               maxwindow = assert(args.n) -- default is 20, or set by user
               prev = {}
               
               -- print out the headers for the output, if these are asked for. 
                 if args.H == true then
                 
                          if args.s == false and args.r == false then
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
                                         "low_date"                         -- low date
                                  )
                           elseif args.s == true and args.r == false then 
                                 print(  "ts_id" .. args.OFS ..      -- this is the timeseries id
                                         "opendate" .. args.OFS ..          -- bar open date
                                         "closedate"  .. args.OFS ..        -- bar close date
                                         "offsetdate" .. args.OFS ..        -- the offset's date
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
                           elseif args.r == true then
                                print(
                                  "ts_id"        .. args.OFS ..           -- this is the timeseries id
                                  "date"         .. args.OFS ..           -- bar open date
                                  "value"        .. args.OFS ..           -- bar open date   ric,date,price,info,pass,start_date,start_price
                                  "info"         .. args.OFS ..           -- the timeframe
                                  "pass"         -- .. args.OFS ..           -- the pass number for multipass
                                  -- "bardate"                               -- the date of the FHLS "bar" you can join back to for graphing purposes.                   
                                )
                           end
                 end            

       
               
          --}{BODY - loop through the data stream.
          
               for r in streamhandle:lines() do            
                 offset = offset + 1
                 
                 -- rather than do complex stuff to calculate offsets, easy to just rotate the values here on mod of N
                 if offset % args.n == 0 then
                      off, poff = offset, off
                 end  

                 -- on start up, we have 
                 frame = math.min(maxwindow, offset) -- set the frame as the smallest of maxwindow, or the row count.


                     -- fhls[offset] = {} -- create an initial table for fhls summaries.
                     -- for this offset record, generate a FHLS bar having a timeframe of only 1 observation (this one)
                 fhls[offset] = {}  
                 trend[offset] = {}   
                 -- configure the first fhls[offset][tf] FHLS record (tf = 1) for each obs, stack up the rest to maxwindow size      
                 -- note we set this for each arriving observation. 
                                    
                 fhls[offset][1] = {d = r.date, od = r.date, cd = r.date, f = r.last, h = r.last, l = r.last, s = r.last, hd = r.date, ld = r.date, fd = r.date, sd = r.date}
                 trend[offset][1] = {lasttrend = 0, lastod = r.date}
                    
                 
                 -- end of first item of the timeframe stack processing, start triangular build
                 -- incremenatlly generate the FHLS data for all other timeframes having history, so offset > 1
               
                 if offset > 1 then
                 
                    rt = ""
                    local sum_rt = 0
                    local prev ={}
                    
                    -- local ffd, ssd = nil

                    -- this is a critical loop, counting up to the frame (N or as high as possible) 
                    for t = 1, (frame -1) do   
                      local p = offset - 1  -- the row right behind the leading data edge     
                                  
                      local tf, opendate, closedate, ff, hh, ll, ss, hhd, lld, ffd, ssd = update_bar(t, r.date, fhls[p][t].od, r.last, fhls[p][t].f, fhls[p][t].h, fhls[p][t].l, fhls[p][t].s, fhls[p][t].hd, fhls[p][t].ld, fhls[p][t].fd, fhls[p][t].sd)  

                      fhls[offset][tf] = {d = r.date, od = opendate, cd = closedate, f = ff, h = hh, l = ll, s = ss, hd = hhd, ld = lld, fd = ffd, sd = ssd}                      

                            if tf == (args.n) and offset%(args.n) == 0 then                              
                               
                               -- r.date records the date of the Last obs in a timewindow, but our FHLS output pegs the row to the START. Retrieve it here:
                               -- bar_date = fhls[offset - args.n][1].d  
                               
                               if offset / args.n > 1 then
                                   -- prev = fhls[offset - args.n][tf] -- set prev as prev bar values
                                   -- (i set this the long way to be clear what's in the prev record)
                                   prev = {  d = fhls[offset - args.n][tf].d
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
                                      if args.r == false then
                                        print(      -- this is the rowid of the input file, the offset
                                               r.ric  .. args.OFS ..      -- this is the timeseries id
                                               opendate .. args.OFS ..    -- bar open date
                                               closedate .. args.OFS ..   -- bar close date
                                               r.date .. args.OFS ..      -- offset date of publish
                                               offset .. args.OFS ..      -- offset of the close
                                               tf .. args.OFS  ..         -- this is the time frame
                                               r.last .. args.OFS ..      -- the closing price/value
                                               ff .. args.OFS ..          -- first of high or low
                                               hh .. args.OFS ..          -- high 
                                               ll .. args.OFS ..          -- low
                                               ss .. args.OFS ..          -- second of high or low
                                               hhd .. args.OFS ..         -- high date
                                               lld -- .. args.OFS ..         -- low date
                                               -- ffd .. args.OFS ..         -- first date
                                               -- ssd                        -- second date                                                    
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
                                        
                                        -- now overwrite the cached trend with the c
                                        trend[offset][tf] = {lasttrend = splittrend}
                                        
                                        if args.r == false then
                                                -- print the splitbar just before printing the normal bar
                                                print(                        -- this is the rowid of the input file, the offset
                                                 r.ric  .. args.OFS ..        -- this is the timeseries id                                         
                                                 splitbar.fd .. args.OFS ..         -- bar open date (is the splitbar's first date)
                                                 splitbar.sd .. args.OFS ..         -- bar close date (is the splitbar's second date)
                                                 r.date .. args.OFS ..        -- offset's date of publish                                         
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
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this  is the timeseries id     
                                                         prev.hd      .. args.OFS ..        -- high date
                                                         prev.h       .. args.OFS ..        -- high
                                                         "Top"            .. args.OFS ..        -- this is the time frame
                                                         args.p           --.. args.OFS ..        -- user pass id
                                                         -- prev.od                            -- the bar open date is the "bar date"
                                                        )
                                              elseif trend[poff][tf].lasttrend == -1 then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         prev.ld      .. args.OFS ..        -- low date
                                                         prev.l       .. args.OFS ..        -- low
                                                         "Bottom"         .. args.OFS ..        -- this is the time frame
                                                         args.p          -- .. args.OFS ..        -- user pass id
                                                         --prev.od                            -- the bar open date is the "bar date"
                                                        )
                                              
                                              end
                                           end
                                        end 
                                      
                                      

                                        local complextrend = sign(sign(hh - splitbar.h) + sign(ll - splitbar.l))
                                        
                                        if complextrend == 0 then
                                          complextrend = splittrend
                                        end
                                        
                                        trend[offset][tf] = {lasttrend = complextrend} -- this overwrites the simple 0 assignment made earlier
                                        
                                        if args.r == false then                                      
                                              -- here we print out the inner or outer bar aggregate bar with strend based on this to the split bar 
                                              print(                           -- this is the rowid of the input file, the offset
                                                 r.ric  .. args.OFS ..         -- this is the timeseries id
                                                 splitbar.sd     .. args.OFS ..         -- bar open date, shifted to the split bar's second date (of final high / low)
                                                 r.date .. args.OFS ..         -- bar close date 
                                                 r.date .. args.OFS ..         -- the offset publish date
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
                                        if args.r == true then
                                           if complextrend == splittrend * -1 then
                                              -- we must print the reversal found when comparing the complex bar to the splitbar
                                              if splittrend == 1 then  -- the split bar is the high
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this  is the timeseries id     
                                                         splitbar.hd      .. args.OFS ..        -- high date
                                                         splitbar.h       .. args.OFS ..        -- high
                                                         "Top"            .. args.OFS ..        -- this is the time frame
                                                         args.p       --    .. args.OFS ..        -- user pass id
                                                         --prev.sd                            -- the bar open date is the "bar date"
                                                        )
                                              elseif splittrend == -1 then
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         splitbar.ld      .. args.OFS ..        -- low date
                                                         splitbar.l       .. args.OFS ..        -- low
                                                         "Bottom"         .. args.OFS ..        -- this is the time frame
                                                         args.p           --.. args.OFS ..        -- user pass id
                                                         --prev.sd                            -- the bar open date is the "bar date"
                                                        )
                                              
                                              end
                                           end
                                        end 

                                      else -- this is a simple bar, so print a simple -s shaped bar
                                                                              
                                      -- here we print out the normal aggregate bar.  
                                      trend[offset][tf] = {lasttrend = strend} 
                                      if args.r == false then
                                            print(      -- this is the rowid of the input file, the offset
                                               r.ric  .. args.OFS ..         -- this is the timeseries id
                                               opendate .. args.OFS ..       -- the bar open date
                                               r.date .. args.OFS ..         -- the closing date of this offset
                                               r.date .. args.OFS ..         -- the offset date of this offset                                         
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
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         prev.hd          .. args.OFS ..        -- high date
                                                         prev.h           .. args.OFS ..        -- high
                                                         "Top"       .. args.OFS ..        -- this is the time frame
                                                         args.p          --  .. args.OFS ..        -- user pass id
                                                         -- prev.od                            -- the bar open date is the "bar date"
                                                        )
                                              elseif pv.lasttrend == -1 then -- the prev bar is the low
                                                  print(
                                                         r.ric            .. args.OFS ..        -- this is the timeseries id     
                                                         prev.ld          .. args.OFS ..        -- low date
                                                         prev.l           .. args.OFS ..        -- low
                                                         "Bottom"    .. args.OFS ..        -- this is the time frame
                                                         args.p          --  .. args.OFS ..        -- user pass id
                                                        --  prev.od                            -- the bar open date is the "bar date"
                                                        )
                                              end
                                           end
                                        end 
                  
                                      end -- end of: if strend == 0 then
                                end
                             -- to create the splitbars in the future, we save the current values into prev.
                             -- prev = {f = ff, h = hh, l = ll, s = ss, hd = hhd, ld = lld, fd = ffd, sd = ssd} 

                            end -- end of bar boundary
                            
                                        
                    --  end -- end of offset > (tf*5)       
                    end                    -- end of for t = 1, (frame -1) do
                        --pretty.dump(fhls[offset][frame]) 
                        
                            
                       -- delete array older than is needed (say 5 widest bars?), to keep memory consumption low                         
                 end --  end of  if offset > 1 then

                if offset > args.n*3+1 then 
                -- delete array older than is needed (say 3 widest bars?), to keep memory consumption low
                  fhls[offset - args.n*3+1] = nil                           
                end                   



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
