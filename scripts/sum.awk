{   
for (i=1; i<=NF; i++) { sum[i]+= $i }   
}

END { 
for (i=1; i<NF; i++ ) 
  { printf sum[i]" "; }
  printf sum[NF]"\n";
}


