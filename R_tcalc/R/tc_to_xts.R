
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



## you pass it the data.table that comes out of tc.data.table, along with the pass level of interest, it turns this into XTS format for plotting in quantmod 


tc.to.xts <- function(  dataobj
			, pass=1  
			){
	p <- pass
	name <- deparse(substitute(dataobj))
	dates <- dataobj[pass==p,date]
	values <- dataobj[pass==p,value] 
       
	index <- as.data.frame(as.POSIXct(dates, format = "%Y-%m-%"))
 
	#mydataframe <<- as.data.frame(cbind(dates,values),stringsAsFactors=False)
	mydf <- as.data.frame(values)

	#z <- as.zoo(mydataframe)

	x <- as.xts(values,order.by = index )
	mode(x) <- "numeric"
	return(x)
}





