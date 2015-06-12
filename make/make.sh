

## apologies - this is not a real make file. Just my experimentations.
##
## I'm testing compiling my luascripts, using luajit and gcc on os/x

## It is highly likely this code won't work for anyone else but me without
## some editing. I include it for reference and as a worked example. 

## To get it working for you, install luajit, and find it's include and libs directories.
## then set them out for gcc using -I<lincudes_dir> -L<libs>
## As I am using an install of torch7, my compiler is set to find it's includes and libs

rm trendcalculus.o
rm reversal.o

rm trendcalculus.lua
rm reversal.lua

rm /usr/local/bin/tcalc
rm /usr/local/bin/trev

## adjust this to point to your luajit include / lib directories

luajit_include_dir="/Users/andrewmorgan/torch/install/include"
luajit_lib_dir="/Users/andrewmorgan/torch/install/lib"

## copy over the latest code to compile locally

cp ../trendcalculus.lua trendcalculus.lua  
cp ../rev.lua           reversal.lua

## use luajit to produce the .o files for the program

luajit -b trendcalculus.lua trendcalculus.o
luajit -b reversal.lua reversal.o


## this worked on ubuntu when compiling tcalc which was an early iteration of the code.
## gcc -std=c99 -Wall -Wl,-E -o tcalc5.exe app1.c tcalc5.o -I/usr/local/include -L/usr/local/lib -lluajit -lm -ldl
##  
## on my mac this is the gcc command that compiles the code. It works on my machine:
## Andrews-MacBook-Pro.local 14.3.0 Darwin Kernel Version 14.3.0: Mon Mar 23 20:23:44 PDT 2015; root:xnu-2782.20.48~8/RELEASE_X86_64 x86_64
##

## produce a statically compiled program which I copy to /usr/local/bin so I can use it anywhere on the file system.
 
gcc -std=c99 -o tcalc trendcalculus.c trendcalculus.o -I${luajit_include_dir} -L${luajit_lib_dir} -lluajit -lm -ldl -pagezero_size 10000 -image_base 10000000
gcc -std=c99 -o trev reversal.c reversal.o -I${luajit_include_dir} -L${luajit_lib_dir} -lluajit -lm -ldl -pagezero_size 10000 -image_base 10000000

## set the permissions on the new compiled code so it's executable
chmod +x tcalc
chmod +x trev

## now copy this over to local/bin so I can use it everywhere on the command line.
mv tcalc /usr/local/bin/. 
mv trev /usr/local/bin/.



## ------------------------------ other notes:
## to compile with clang
## this helped: http://stackoverflow.com/questions/13359821/luajit2-0-0-segmentation-fault-11
##    clang -o trendcalculus trendcalculus.c -O3 -I/Users/andrewmorgan/torch/install/include -L/Users/andrewmorgan/torch/install/lib -lluajit -pagezero_size 10000 -image_base 100000000
## note the clang compile isn't static, and the dynamic linking isn't working. Probably paths need adjusting to get it to work.


