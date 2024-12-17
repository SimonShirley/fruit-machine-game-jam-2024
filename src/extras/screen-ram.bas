100 print "vic-ii character memory locator"
105 print chr$(147)
110 print "------------------------------"
130 v=peek(53272) : rem read the value from 53272
140 print "value at 53272 = ";v;
150 b = v
160 l = 7
170 print " (bin "; : gosub 3000
180 print ")"
200 rem calculate screen ram address
210 s=int(v/16) : rem get the 4 most significant bits
220 print "4 msb: "; s; "dec ";
230 b = s
240 l = 4
250 print "(bin "; : gosub 3000
260 a=s*1024
270 print ")"
280 print "screen ram address: ";a
300 rem calculate character set address
310 c=(v and 14)/2 : rem get bits 1-3
320 print "3 lsb: "; c; "dec";
330 b = c
340 l = 3
350 print " (bin "; : gosub 3000
360 a=c*2048
370 print ")"
380 print "character set address: ";a
400 end
3000 rem binary conversion
3010 n$ = ""
3020 for i=7 to 0 step -1
3030 rem if i < l then goto 3060
3040 n$ = n$ + chr$(48 + int(b/2^i))
3050 b=b-(int(b/2^i)*2^i)
3060 next i
3070 print right$(n$,l);
3075 print "{186}{184}{184}{184}{184}{184}{184}{184}{184}{184}"
3080 return 