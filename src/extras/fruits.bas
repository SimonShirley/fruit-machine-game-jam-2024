10 print chr$(147)
20 print "generated with spritemate"
30 print "7 of 7 sprites displayed."
40 poke 53285,10: rem multicolor 1
50 poke 53286,2: rem multicolor 2
60 poke 53269,255 : rem set all 8 sprites visible
70 for x=12800 to 12800+447: read y: poke x,y: next x: rem sprite generation
80 :: rem cherry
90 poke 53287,1: rem color = 1
100 poke 2040,200: rem pointer
110 poke 53248, 44: rem x pos
120 poke 53249, 120: rem y pos
130 :: rem pear
140 poke 53288,0: rem color = 0
150 poke 2041,201: rem pointer
160 poke 53250, 92: rem x pos
170 poke 53251, 120: rem y pos
180 :: rem lemon
190 poke 53289,0: rem color = 0
200 poke 2042,202: rem pointer
210 poke 53252, 140: rem x pos
220 poke 53253, 120: rem y pos
230 :: rem grape
240 poke 53290,1: rem color = 1
250 poke 2043,203: rem pointer
260 poke 53254, 188: rem x pos
270 poke 53255, 120: rem y pos
280 :: rem apple
290 poke 53291,0: rem color = 0
300 poke 2044,204: rem pointer
310 poke 53256, 44: rem x pos
320 poke 53257, 172: rem y pos
330 :: rem seven
340 poke 53292,1: rem color = 1
350 poke 2045,205: rem pointer
360 poke 53258, 92: rem x pos
370 poke 53259, 172: rem y pos
380 :: rem bar
390 poke 53293,0: rem color = 0
400 poke 2046,206: rem pointer
410 poke 53260, 140: rem x pos
420 poke 53261, 172: rem y pos
430 poke 53276, 127: rem multicolor
440 poke 53277, 0: rem width
450 poke 53271, 0: rem height
1000 :: rem cherry / multicolor / color: 1
1010 data 0,0,0,0,0,0,0,0,0,0,0,64,0,3,240,0
1020 data 3,16,0,13,0,0,12,0,0,31,0,0,255,192,0,192
1030 data 192,1,64,80,7,113,220,5,113,92,5,113,92,1,192,112
1040 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,129
1050 :: rem pear / multicolor / color: 0
1060 data 0,0,0,0,0,0,0,12,0,0,15,0,0,12,0,0
1070 data 12,0,0,20,0,0,215,0,0,85,192,0,93,64,3,85
1080 data 112,13,85,80,13,215,92,13,85,92,13,93,92,3,85,112
1090 data 0,213,192,0,63,0,0,0,0,0,0,0,0,0,0,128
1100 :: rem lemon / multicolor / color: 0
1110 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
1120 data 20,0,0,117,0,1,85,64,5,215,80,21,85,116,23,119
1130 data 84,53,85,92,13,221,112,3,85,192,0,215,0,0,60,0
1140 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128
1150 :: rem grape / multicolor / color: 1
1160 data 0,0,0,0,0,0,0,0,12,0,0,60,0,0,240,0
1170 data 15,192,0,48,64,0,17,80,0,87,112,3,220,192,1,49
1180 data 0,5,69,64,13,205,192,3,19,0,4,84,0,21,220,0
1190 data 55,48,0,12,0,0,0,0,0,0,0,0,0,0,0,129
1200 :: rem apple / multicolor / color: 0
1210 data 0,0,0,0,0,0,0,12,0,0,15,0,0,12,0,0
1220 data 20,0,0,85,0,1,85,64,1,85,192,5,87,0,5,92
1230 data 0,5,92,0,5,87,0,13,85,192,1,85,64,3,85,192
1240 data 0,215,0,0,60,0,0,0,0,0,0,0,0,0,0,128
1250 :: rem seven / multicolor / color: 1
1260 data 0,0,0,0,0,0,0,0,0,0,0,0,1,85,64,1
1270 data 85,64,3,253,64,0,1,64,0,5,64,0,5,192,0,21
1280 data 0,0,23,0,0,84,0,0,92,0,0,80,0,0,80,0
1290 data 0,240,0,0,0,0,0,0,0,0,0,0,0,0,0,129
1300 :: rem bar / multicolor / color: 0
1310 data 0,0,0,0,0,0,0,0,0,0,0,0,85,85,85,255
1320 data 255,255,0,0,0,20,4,20,29,29,29,17,17,17,23,21
1330 data 23,29,29,29,17,17,17,23,17,17,60,51,51,0,0,0
1340 data 85,85,85,255,255,255,0,0,0,0,0,0,0,0,0,128
