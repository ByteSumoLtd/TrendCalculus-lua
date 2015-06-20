              |       |     
              |--\  /-|-.-.             .
              |__/\/  | \/_            . :.
               ___/ _   _  _  __   ___/ . .
              / ._|| | | || \/  \ /   \ . : .: 
              \_  \| |_| || | | || [ ] | .. 
              \___/|____/||_|_|_| \___/ ..
                                  / . ..  .:
                                   .: .  .:  
                


# TrendCalculus: Streaming Multi-Scale Trend Change Detection Algorithm #

  Author:  Andrew J Morgan

  Version: 1.0.0

  Source:  https://bitbucket.org/bytesumo/trendcalculus-public

# Description #

TrendCalculus is my algorithm for enabling fast, bottom up, hierarchical trendwise partitioning of timeseries data using a model-free approach which is extremely efficient.

### How ###

To learn how to run the code, check the help and version info using the -v option.
A detailed help me and usage notes will be produced.

> lua trendcalculus.lua -v

The scripts run like a command line app, accepting stdin or a named file using the -f option.

Test the software using the bash script for testing:

> . test.sh


### Calling TrendCalculus from R ###

A minimalistic integration with R included (but it is a bit of a hack). 
to use it: Install devtools. libary(devtools)
then set the working directory to trendcalculus-public 

>libary(quantmod)

>setwd = "~/trendcalculus-public"

>load_all("R_tcalc")

>getSymbols("BP.L")

>BP.Close <- BP.L[,4]

>head(BP.Close)

>tc.data.table(BP.Close)

The output will be a data.table which can be used in further anlaysis.

### Help ###

Questions can be posted at the google group set up for the code, or you can ask them in person at one of the meetups that are held in London:

See:
https://groups.google.com/forum/#!forum/trendcalculus

http://www.meetup.com/Trendwise-Research-London

### License ###

GPLv3
 
### Dependencies ###

The code should work with zero dependencies.
Execute it using luajit, lua 5.1 or lua 5.2.
It should run out the box as is once you can execute lua on the command line.

Note:
pl.lapp, csv, and date all all luarocks that I have embedded in this code already as part of the release.
So nothing to do, nothing to install. Just run it.

         
# References:

http://bytesumo.com/blog/2015/01/trendcalculus-data-science-studying-trends

https://bitbucket.org/bytesumo/trendcalculus-public

https://github.com/geoffleyland/lua-csv

https://github.com/stevedonovan/Penlight

http://tieske.github.io/date/
