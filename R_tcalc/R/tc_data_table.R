
# ---------------------------------------------------------------------------------
#
#             
#               |       |     
#               |--\  /-|-.-.             .
#               |__/\/  | \/_            . :.
#                ___/ _   _  _  __   ___/ . .
#               / ._|| | | || \/  \ /   \ . : .: 
#               \_  \| |_| || | | || [ ] | .. 
#               \___/|____/||_|_|_| \___/ ..
#                                   / . ..  .:
#                                    .: .  .:  
#                
#
#
#   TrendCalculus: Streaming Multi-Scale Trend Change Detection Algorithm
#
#   Copyright 2014-2015, ByteSumo Limited (Andrew J Morgan)
#
#   Author:  Andrew J Morgan
#   Version: 1.0.0
#   License: GPLv3
#
#     This file is part of TrendCalculus.
#
#     TrendCalculus is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     TrendCalculus is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with TrendCalculus.  If not, see <http://www.gnu.org/licenses/>.
#
#
# ---------------------------------------------------------------------------------
## function: tc.data.table
## input: zoo object having date/time as an index, and one column holding the value overwhich to find reversals 

## you pass it an xts 

tc.data.table <- function(dataobj, n=2 , pass=1, setdirectory="/Users/andrewmorgan/trendcalculus-public", luapath="PATH=~/torch/install/bin:$PATH", luaexe="luajit"){

  ## set out the flags and conditional processing
  output <- "-r"
  win    <- "-n"
  p      <- "-p"
  tfile  <- "-f"
  h      <- "-h"
  H      <- "-H"

## conditionally set the headers to read back in good data
rn <-c('ts_id', 'date', 'value', 'info', 'pass')

closes <- as.data.frame(dataobj)
closes$ts_id = deparse(substitute(dataobj))

names(closes)[1]<-"date,close"
names(closes)[2]<-"ts_id"

tmpf <- "r_in.csv"
tmpout  <- "r_out.csv"

dirtmp  <- paste(setdirectory, "/", "data", "/", "r_in.csv", sep ="")
dirrtmp <- paste(setdirectory, "/", "out", "/", "r_out.csv", sep ="")

## this will write out the csv format data I need.

write.table(closes, file = dirtmp, quote = F, col.names = T, sep=",") 

## now all the wrangling is done, push the data through the program and read it back in as a zoo object

cmdstring <- paste("cd", setdirectory, ";", "export", luapath, ";"
				   ,      luaexe, "trendcalculus.lua", h, H, p, "1", output, win, n,   tfile, dirtmp, "|tee",    dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "2", output, win, "2",              "|tee -a", dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "3", output, win, "2",              "|tee -a", dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "4", output, win, "2",              "|tee -a", dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "5", output, win, "2",              "|tee -a", dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "6", output, win, "2",              "|tee -a", dirrtmp
				   , "|", luaexe, "trendcalculus.lua", h, H, p, "7", output, win, "2",              "|tee -a", dirrtmp
				   , ";" , "head -1 out/r_out.csv > out/fread.csv; cat out/r_out.csv | grep -v pass >> out/fread.csv"			   
              , sep = " ")

cat(cmdstring, file = file.path(setdirectory, "R_tcalc/tmp", "cmdstring.sh"))
cmdstring2 <- paste("cd ", setdirectory, "; . R_tcalc/tmp/cmdstring.sh", sep="")

system(cmdstring2)

#print("starting to read in data")
fetch <- paste(setdirectory, "/out/fread.csv", sep = "")
#print(fetch)

rev <- fread(input=fetch)

#file.remove(fetch)
#file.remove(dirtmp)
#file.remove(dirrtmp)

# now set the index in the data.table:
setkey(rev, ts_id, pass)

return(rev)
}


