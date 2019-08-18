#!/usr/bin/gawk -f
#%SUMMARY: for each stdin hex addr search nearest boundaries inside reference file
#%USAGE: $ ./$0 ./hexaddr-segments - < ./hexaddr-lines
#ALT:(oneliner): gawk -vOFS=" -> " 'FNR==NR{++n;s[n]=strtonum("0x"$1);S[n]=$0} FNR!=NR{a=strtonum("0x"$1);l=1;h=n;if(a>=s[l]&&a<s[h]){while(l<h){m=l+int((h-l)/2)+1;if(s[m]>a){h=m-1}else{l=m}};$2=(s[m]==a)?S[m]:S[l]}print}' ./symtable -

BEGIN {
  OFS = " -> "
}

FNR==NR {
  ++n
  s[n] = strtonum("0x"$1)
  S[n] = $0
  next
}

{
  a=strtonum("0x"$1)
  l=1
  h=n
  if(a >= s[l] && a < s[h]) {
    while(l<h){
      m = l + int((h-l)/2) + 1
      if(s[m] > a) { h = m-1 } else { l = m }
    }
    $2 = (s[m]==a) ? S[m] : S[l]
  }
  print
}
