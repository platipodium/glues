#!/bin/bash

TABLE=missing_redfit_table_0.5.tsv

#bash print_missing_redfit_table.sh > $TABLE

head -1 $TABLE
 awk ' $NR>1 { printf "%40s ",$1 ; s=0; for ( i=2; i<= NF ; i++ ) {s=s+$i  ; printf "%11d",$i } ; printf "%11d",s ; print ""}' $TABLE


