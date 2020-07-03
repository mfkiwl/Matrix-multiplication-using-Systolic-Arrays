force clk 0 0ns , 1 10ns -repeat 20ns
force start 1 0ns , 0 20ns, 1 30ns , 0 40ns, 1 50ns, 0 60ns
force reset 1 0ns , 0 20ns 
force fpnum1 00 0ns, 30 30ns, 48 50ns
force fpnum2 00 0ns, 30 30ns,  48 50ns

run 200ns
