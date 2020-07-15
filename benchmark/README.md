# benchmark trend reversal data

I have included a script in the top directory called benchmark.sh
If you execute it, assuming you have lua installed, it will produce the data in this directory.
The purpose of these files is to provide a data quality benchmark, to prove that your implementation of TrendCalculus 
produces the same results as the reference implementation.

The files read in dirty min data for the SPX at a minute level, closing prices on bars only, and passes them through successive 
passes of the trendcalculus algorithm, to stack up reversals into a multi-scale trend ouput.

To test your implementation, try and recreate these files, and test they are equivalent.

Andrew
