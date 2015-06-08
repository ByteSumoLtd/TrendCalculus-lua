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

# Description #

TrendCalculus is my algorithm for enabling fast, bottom up, hierarchical trendwise partitioning of timeseries data using a model-free approach which is extremely efficient.

### How ###

To learn how to run the code, run the code and apply the -v option:

> lua trendcalculus.lua -v

The scripts run like a command line app, accepting stdin or a named file using the -f option.
Questions can be posted to andrew at bytesumo.com

### License ###

GPLv3
 
### Dependencies ###

The code should work with zero dependencies.
Execute it using luajit, lua 5.1 or lua 5.2.
It should run out the box as is.

Note:
pl.lapp, csv, and date all all luarocks that I have embedded in this code already as part of the release.
So nothing to do, nothing to install. Just run it.

         
# References:

http://bytesumo.com/blog/2015/01/trendcalculus-data-science-studying-trends
https://bitbucket.org/bytesumo/trendcalculus-public

https://github.com/geoffleyland/lua-csv

https://github.com/stevedonovan/Penlight

http://tieske.github.io/date/