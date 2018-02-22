pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
---runs the game starting with the title screen
function _init()
	titleinit()
	title={}
	title.lantern=10
	coins={}
	food={}
	mushroom={}
	mushroom.pic=23
	evilplant={}
	evilplant.pic=42
	food.y=0
	coins.pic=38
	step=0
	score=00000
end

---creates all variables for the game
function gameinit()
	mode=1
	px=160    -- x-position
	py=240   -- y-position
	pstate=0 -- current player state
	pspr=1   -- current sprite
	pdir=0   -- current direction
	pat=0    -- player state timer
	lvl=1
	camx=128
	camy=128
	floor=0
	ceiling=0
	leftwall=0
	rightwall=0
	hp=6
end

---enables mode to be at 0 which where
---our update() function below will be called
function titleinit()
	mode=0
end

---the update loop to either run the title screen
---or begin to run the game_update60() function
function _update()
	if (mode==0) then
		titleupdate()
	elseif (mode==2) then
	
	else
		game_update60()
	end
end

---begins our draw function to draw all of our sprites
function _draw()
	-- clears screen
	cls()
	rectfill(136,8,248,248,12)
	rectfill(264,8,376,248,12)
	-- places camera at 1st level
	camera(camx, camy)
	-- draw the world
	map(0,0,0,0,128,512)
	-- title screen
	print("sakajo's adventures", 27, 42, 200)  
	print("press z to start", 32, 64, 7)
 lvl_items(lvl)
 lvl_enemies(lvl)
 if mode==1 then
 -- draw the player
	spr(pspr,px,py,1,1,pdir==-1)
 health_bar(hp)
 end
end

---this is where our camera moves when the player
---advances throughout the levels
function update_camera(lvl)
	if lvl==1 then
		if py < 135 then
			camy = 0
		else
			camy = 128
		end
		floor=244
		ceiling=8
		leftwall=136
	 rightwall=240
	end
end

---changes the state of the player to know
---which sprite to draw when the player is
---performing any action
function change_state(s)
	pstate=s
	pat=0
end

function canfall()
 -- get the map tile under the player
 v=mget(flr((px+4)/8),flr((py+8)/8))
 -- see if its flagged as wall
 return not fget(v,0)
end

function titleupdate()
		title_screen()
		title.lantern+=1
  if(title.lantern>12) title.lantern=10
print("press z to start", 32, 64, 7)
if btn(4,0) then
 gameinit()
end

end
function game_update60() 
if(fget(mget(pixel(px+7),pixel(py)),2))==true then hp-=1 end
if(fget(mget(pixel(px+7),pixel(py)),7))==true then score+=100 end

  coins.pic+=0.2
  food.y+=0.15
  mushroom.pic+=0.09
  evilplant.pic+=0.05
  
  if(evilplant.pic>44) evilplant.pic=42
  if(mushroom.pic>26) mushroom.pic=23
  if(food.y>3) food.y=0
  if(coins.pic>42) coins.pic=38
  
 left=btn(⬅️) -- button0 state
 right=btn(➡️) -- button1 state
 jump=btn(🅾️) -- button2 state
 shoot=btnp(❎)

 //px%=128   -- no bounds
 pat+=1    -- increment timer

 -- idle state
 if pstate==0 then
   pspr=3      -- idle sprite
   if (left or right) change_state(1)
   if (jump) then
     change_state(3)
     sfx(01)
   end
   if (canfall()) change_state(2)
 end
 
 -- walk state
 if pstate==1 then
   if (pat%3==0) then sfx(0) end -- sound
   if (left and px>leftwall) then -- set direction
     pdir=-1
   elseif (left and jump and px>leftwall) then
     pdir=-1
     sfx(01)
   else pdir=0
   end
   
   if (right and px<rightwall) then -- set direction
     pdir=1
   elseif (right and jump and px<rightwall) then
     pdir=-1
     sfx(01)
   end
   
   if (jump) then
     change_state(3)
     sfx(01)
   end
   if (canfall()) change_state(2)
   -- move the player
   px+=(pdir*.75)*min(pat,2)
   pspr=flr(pat/2)%2
   if (not (left or right)) change_state(0)
 end

 -- fall state
 if pstate==2 then
   	pspr=2
   if (canfall()) then
   if (left and px>leftwall) px-=1
   if (right and px<rightwall) px+=1
   	py+=min(4,pat)
   if (not canfall()) py=flr(py/8)*8
   else
    py=flr(py/8)*8
    sfx(2) -- ground contact sfx
   	change_state(0)
   end
 end
 
  -- jump state
 if pstate==3 then
 if(py<ceiling) pstate=2
   if (pat==1 and py>ceiling) sfx(0) -- play sfx
   pspr=2
   py-=7-pat
   if (left and px>leftwall) px-=2 pdir=-1
   if (right and px<rightwall) px+=2 pdir=1
   if (not jump or pat>7) then
     if (not canfall()) py=py-py%8
     change_state(0)
   end
 end
 update_camera(lvl)
 
 if (shoot) then
 hp-=1
 mset(pixel(px+8),pixel(py),53)
 end
 
end

function tile(tile)
return flr(tile*8)
end

function pixel(pixel)
return flr(pixel/8)
end

function lvl_items(clevel)
if clevel==1 then
add(coins,
	mset(30,27,coins.pic),
	mset(29,27,coins.pic),
	mset(28,27,coins.pic),
	mset(27,27,coins.pic),
	mset(17,24,coins.pic),
	mset(18,24,coins.pic),
	mset(19,24,coins.pic),
	mset(29,21,coins.pic),
	mset(30,21,coins.pic),
	mset(23,18,coins.pic),
	mset(24,18,coins.pic),
	mset(22,26,coins.pic),
	mset(23,26,coins.pic))
	spr(27,tile(17),111+food.y)
	spr(30,tile(30),79+food.y)
	spr(64,tile(26),tile(29))
	spr(80,tile(26),tile(30))
end
end

function lvl_enemies(clevel)
if clevel==1 then
	mset(30,30,mushroom.pic)
 mset(29,30,mushroom.pic)
	mset(28,30,mushroom.pic)
	spr(evilplant.pic,tile(22),tile(24))
end
end

function title_screen()
	spr(title.lantern,16,72)
end

function health_bar(health)
map(0,16,camx,camy,16,1)
print(score,camx,camy,7)
if health==6 then
spr(56,camx+102,camy)
spr(56,camx+111,camy)
spr(56,camx+120,camy)
elseif health==5 then
spr(56,camx+102,camy)
spr(56,camx+111,camy)
spr(57,camx+120,camy)
elseif health==4 then
spr(56,camx+102,camy)
spr(56,camx+111,camy)
spr(58,camx+120,camy)
elseif health==3 then
spr(56,camx+102,camy)
spr(57,camx+111,camy)
spr(58,camx+120,camy)
elseif health==2 then
spr(56,camx+102,camy)
spr(58,camx+111,camy)
spr(58,camx+120,camy)
elseif health==1 then
spr(57,camx+102,camy)
spr(58,camx+111,camy)
spr(58,camx+120,camy)
else
spr(58,camx+102,camy)
spr(58,camx+111,camy)
spr(58,camx+120,camy)
end
end
__gfx__
85555550055555508555555085555550000000009999990990990000007776000777650000000000005555000055550000111110000000000000000000000000
08888880088888800888888008888880000000000099999990999999075757600005500000000000057777500577775001fcfcf0000000000000000000b07000
0ff1f1f08ff1f1f00ff1f1f00ff1f1f0000000009999990999999900077777600777777000000000050000500500005000fffff00000000000007000000000b0
05555550055555500555555005555550000000000000900090999999777777767677760707777760050090500500805000777770000b700000b0000007000000
555555555555555555555555555555550000000099999909000900007777777670076007777776550509805005089050077777770007b00000000b0000000070
0555555005555550055555500555555000000000009999999099999977777776707776077878765505089850059980500011111000000000000700000b000000
01155550055551100115511005555550000000009999990999999900076767600070070077777655505985055058950500777770000000000000000000070b00
00000550055000000000000005500550000000000000990990999999000000000760760007776550555555555555555500077700000000000000000000000000
555555550000000044494444444444444444444900000000656565650000000000000000000000000000040000e0000000333300000000004004000000000eee
555555550000000044444444444944444444444455555055066606660988800000098880009888000009900066666666037777300077760004040000000000ee
55555555000000004944444944444449444494446666606665656565998998000099899809989980000a90040666666037bb99730776777000440000000000ee
55555555000000004444444449444444494444446666606666066606888998000088899808889980099009a006e9996037bb9973677777670ff4f9f049000099
555555550000000044449444444494444444444400000000656565658988888008898888889888880a90099006e9996037aeee73777677779f9f4f9f99900949
55555555000000004444444bb44b44b4b444449405555555066606669977998008997799899779984009900006e5956037eeea73555555555555555599499999
5555555500000000494444bb4b4bbb4bbb44444406666666656565658877780000877788088778800009a0000659596003777730555555555555555509994990
555555550000000044444bbbbbbbbbbbbbb494440666666666066606000770000007700000077000004000000066660000333300055555500555555000999900
000000000000000044449b4bb4bbbbbbb44444449999999900000000000000000000000000000000007507000077770000000000000000000000000000000000
0005666666650000494444bb4bb4b44bbbb444444444444400aaa700009aa0000009a00000077900077057700877778000000000000000000000000000000000
005661117166500044444b4b44444444b4444944444444440a99777009a99a000009a00000779a90777507778e8778e800000000000000000000000000000000
05661ccccc16650044444b4b00000000bb444494444444440a9777a009a99a000009a00000799a90888888e88888888800000000000000000000000000000000
5661cc171cc16650444944bb00000000bb944444999999990a7779a009a997000009a00000a99a908e88e8880e8e88e000000000000000000000000000000000
566cc11111cc665044444b4b00000000b444494444444444077799a009a977000009a00000a99a90008e880000e8880000000000000000000000000000000000
566c1171111c66504444494b00000000bb44444444444444007aaa00009770000009a000000aa90000b33b0000b33b0000000000000000000000000000000000
566111ccc117665094444bbb00000000b44444444444444400000000000000000000000000000000000330000003300000000000000000000000000000000000
56671c111c11665044449bbbbbbbbbbbbbb444440000000000000000000000000990099009900990099009909a99a99a9a99a99a9a59599a9a99a99a00000000
56611c1c1c116650494444bb4b44b4b4bb4444440006000000000600000000009889988998899009900990092222292266666666252a29222222292200000000
56611c1c1c7166504444444bb44b44b4b444494400065000060560000000000097788889977800099000000988848a885554555588a9a58888848a8800000000
56617c111c1166504449444444444444444494440050d660006d05000000000097888889978800099000000984888948545555458a999a488488894800000000
566111ccc1176650444444444444499444444944066d05000050d60000000000988888899888000990000009a99a99a9a99a99a988a9a88888a8888800000000
566c1171111c66504444494494444444449444940005600000065060000000000988889009880090090000909222222292222222888888a8888888a800000000
566cc11117cc6650944444944449444444444444000060000060000000000000009889000098090000900900a4888848a48888488988a8888988a88800000000
5661ccc1ccc166504444444444444444444444440000000000000000000000000009900000099000000990009884888898848888888a8898888a889800000000
00080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00989899000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08989898000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089898000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00990099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff4fff4f00000004440000003bb33300000030000003000003333333333333333333333000000000000000000000000000000000000000000000000000000000
4ff4ffff00000004440000003bb3330000033300003b30003bbbbbbbbbbbbbbbbbbbbbb300000000000000000000000000000000000000000000000000000000
fffffff400000004440000003bb333000003b300003b300003333333333333333333333000000000000000000000000000000000000000000000000000000000
ffffffff00000004440000003bb333000003b333003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000
f4ff4fff00000004440000003bb3330000003bbb333b300000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff400000004440000003bb333330000033b3bb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff4ffff00000004440000003bb333bb00000033bb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ffff4ff00000004440000003bb33333000000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444400000004440000004000000003b330000003333000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000000444000000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000004444000000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000004444400000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000004444400000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000004444440000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000044444440000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440000044444440000400000003bb3330000333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000
000044444444444444444444444440003bb3330000333bb300300000000003000000000000000000000000000000000000000000000000000000000000000000
000044444444444444444444444440003bb3330000333bb303b3000000003b300000000000000000000000000000000000000000000000000000000000000000
000044444444444444444444444440003bb3330000333bb303b3030000303b300000000000000000000000000000000000000000000000000000000000000000
000444444444444444444444444440003bb3330000333bb303b33b0000b33b300000000000000000000000000000000000000000000000000000000000000000
004444444444444444444444444440003bb3330000333bb303bbbb0000bbbb300000000000000000000000000000000000000000000000000000000000000000
044444444444b44444b44444444444003bb3330000333bb303b3000000003b300000000000000000000000000000000000000000000000000000000000000000
044bbb44444bb4444bbb444bb444b4403bb3330000333bb303b3000000003b300000000000000000000000000000000000000000000000000000000000000000
44bbb44b44bbbb44bbbb44bbbb4bbb44033330000003333000300000000003000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000074040000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000404040000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000103010000040404101010101010000002010200808080800404000000000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000003000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1515151515151515151515151515151512131313131313131313131313131314909090909090909090909090909090903333333333131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313133333333333333333333333333333333333331313
1515151515151515151515151515151522000000000000000004000404040424900000000000000000000004040404903300000000000000000000000000001313000000000000000000000000000013133b3b3b3b3b3b3b3b3b3b3b3b3b3b3b1300000000000000000000000000000000000000000000000000000000000013
1515151515151515151515151515151522000000040404040000000400202124900000000000000000000900000004903300000000000000000000000000041313000000000000000000000000000413133b3b3b3b3b3b3b3b3b3b3b3b3b3b3b1300000000000000000000000000000000000000000000000000000000000013
1500000000000000000000000000001522000000040404040404040404303124900004000400000000000800000004903300040004000000000000000000043333000400040000000400040000040433333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522042323232323232323232323232324900404979797979797979797979797903304040404040000040400000004043333040404040400000404040000040433333c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522000004000000000000000000000024900404040400000000000000000000903304040404000000000000000000003333040404040000000404040000040433333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522232323230404040400040000040424909797980400000000000000000000903304040404000000000000000000003333040404040000000404040004040433333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522000000000000000000000000000024900404000000040000000000969797903304040000000400000000000000003333040400000004000404040404040433333b3c3b3c3b3c3b3c3b3c3b3c3b3c3b3300000000000000040404040404040404040404040404040404040404040433
1500000000000000000000000000001522000000040404040400000000000024900404049697979804000004040404903304040400000000040000040404043333040404000000000404040404040433333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000433
1500040404000404000404040404001522000000000000232300000004000024900404040404040404040404040404903304040404040404040404040404043333040404040404040404040404040433333c3b3c3b3c3b3c3b3c3b3c3b3c3b3c3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522000000000004040404040404000024909797980404040496979798040000903304040404040404040404040400003333040404040404040404040404040433333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000040000000000000000001522000000000000000000002300002324900000000000000004040000000000903300000000000000040400000000003333000000000000000404040404040033333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000040000000000000000001522232323232300000000000000000024900000000000000000000000009697903300000000000000000000000000003333000000000000000404040000000033333c3c3c3b3b3b3c3c3c3c3b3b3b3c3c3300000000000000000000000000000000000000000000000000000000000033
1500000000040400000000000000001522000400000000000000000000000024900004009697979804000000000000903300000000000000000000000000003333000000000000000004040000000033333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1500000000000000000000000000001522000000000000000400000000000024900004040404040404000000000000903300000000000000000000000000003333000000000000000000000000000033333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3300000000000000000000000000000000000000000000000000000000000033
1616161616161616161616161616161622230000002323040423230000000024900000000000040404040096979797903300000000000000000000000000003333000000000000000000000000000033333c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3333333333333333333333333333333333333333333333333333333333333333
1010101010101010101010101010101022000000000000000000000000000024909797979804040404040404000000903300000000000000000000000000003333000000000000000000000000000033333d3e3d3e3e3d3d3e3d3e3e3e3d3e3d3333333333333333333333333333333333333333333333333333333333333333
0400000000000000000404040404040422000400000000000000000000000424900000000004040404040004000000903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000000004040422232323000000000004000023232324900004040400049697979798000004903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000033
0400000000000000000404040404040422000000000023232323000000000024900004040004040404040000000000903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000000000c5c522000000000000000000000000000024900000000000040404040000009697903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000000000c5c522000400000000000000000400040024909797979798040404040000000000903300000000000000000000000000003333000000000000000000000000000033330004040404040000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000000000c5c522232323230000000000002323232324900000000000040496980000000000903300000000000000000000000000003333000000000000000000000000000033330004040404040000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000000000c5c522000000000000000000000000000024900000000004040404040400000000903300000000000000000000000000003333000000000000000000000000000033330004040404040000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000004040000c5c522000000000000000004000000000024900000000004040404040496979797903300000000000000000000000000003333000000000000000000000000000033330004040404040000000000000000040400000000000000000000000000000000000000000000000000000000000033
0400000000000000000000040400c5c522232323232323232323230000000024900000969797980404040404000000903300000000000000000000000000003333000000000000000000000000000033330004040404040000000000000000000000000000000000000000000000000000000000000000000000000000000033
040000000000000000000000000404c522040404040426260404040000000024900000000004040404040404040000903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033
040000000000c5c5c5c5c5c5c500040422040404040404040404002626262624900000040404040404040400000000903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033
040000000000c5c5c5c5c5c50000000422040404040404040404042323232324900094a40004049697979800000000903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033
040000000000c5000000c5c5000000c522040404040404040404040000000024900004939504040404040404a59500903300000000000000000000000000003333000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033
040000000000c500c5c5c5c5000000c522000000040400000000000017171724900000b40004040404040404b50000903300000000000000000000000000003333000000000000000000000000000433330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033
0400000000000000c500c500000000c532333333333333333333333333333334909090909090909090909090909090903333333334333333333333333333333333333334333333333333333333333333333433333333333333333333333334333333333333333333333333333333333333333333333333333333333333333333
__sfx__
0010000007100030000710005100041000410005100051000910005100041000410003700027000370001700017000170001700017000670007700087000870009700097000a7000b7001c70024700297002e700
000400001a7401d7402074024720297102f7000b1000b10014100131000f1000e1000f100131001410014100179000f5001150011500189001990019900199001990016900169001590017900189001990019900
__music__
02 41424344

