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
	enemies={}
	enemies.pic=23
	food.y=0
	coins.pic=38
	step=0
	score=00000
end

---creates all variables for the game
function gameinit()
	mode=1
	px=20    -- x-position
	py=496   -- y-position
	pstate=0 -- current player state
	pspr=1   -- current sprite
	pdir=0   -- current direction
	pat=0    -- player state timer
	lvl=1
	camx=0
	camy=384
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
	else
		game_update60()
	end
end

---begins our draw function to draw all of our sprites
function _draw()
	-- clears screen
	cls()
	rectfill(0,264,128,512,12)
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
		if py < 390 and camy>0 then
			camy = 264
		else
			camy = 384
		end
		floor=504
		ceiling=272
		leftwall=8
	 rightwall=112
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
 v=mget(flr((px+2)/8),flr((py+8)/8))
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
  coins.pic+=0.2
  food.y+=0.15
  enemies.pic+=0.09
  if(enemies.pic>26) enemies.pic=23
  if(food.y>2) food.y=0
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
 spr(53,px+10,py)
 end
 
end

function lvl_items(clevel)
if clevel==1 then
	spr(coins.pic,88,480)
	spr(coins.pic,96,480)
	spr(coins.pic,104,480)
	spr(coins.pic,112,480)
	spr(coins.pic,8,472)
	spr(coins.pic,16,472)
	spr(coins.pic,24,472)
	spr(coins.pic,112,432)
	spr(coins.pic,104,432)
	spr(27,8,376+food.y)
	spr(30,112,344+food.y)
end
end

function lvl_enemies(clevel)
if clevel==1 then
	spr(enemies.pic,72,456)
end
end

function title_screen()
	spr(title.lantern,16,72)
end

function health_bar(health)
map(16,0,camx,camy,16,1)
print(score,camx,camy,7)
if health==6 then
spr(56,102,camy)
spr(56,111,camy)
spr(56,120,camy)
elseif health==5 then
spr(56,102,camy)
spr(56,111,camy)
spr(57,120,camy)
elseif health==4 then
spr(56,102,camy)
spr(56,111,camy)
spr(58,120,camy)
elseif health==3 then
spr(56,102,camy)
spr(57,111,camy)
spr(58,120,camy)
elseif health==2 then
spr(56,102,camy)
spr(58,111,camy)
spr(58,120,camy)
elseif health==1 then
spr(57,102,camy)
spr(58,111,camy)
spr(58,120,camy)
else
spr(58,102,camy)
spr(58,111,camy)
spr(58,120,camy)
end
end
__gfx__
85555550055555508555555085555550000000009999990990990000007770000555555000000000005555000055550000555550000000000000000000000000
08888880088888800888888008888880000000000099999990999999070707000555555000777000057777500577775000f1f1f0000000000000000000b07000
0ff1f1f08ff1f1f00ff1f1f00ff1f1f0000000009999990999999900077777000533335007777700050000500500005000fffff00000000000007000000000b0
055555500555555005555550055555500000000000009000909999997777777003a33a3007878700050090500500805000555550000b700000b0000007000000
555555555555555555555555555555550000000099999909000900007777777063333336077777000509805005089050055555550007b00000000b0000000070
0555555005555550055555500555555000000000009999999099999977777770033003300077700005089850059980500088888000000000000700000b000000
01155550055551100115511005555550000000009999990999999900070707000033330000070000505985055058950500555550000000000000000000070b00
00000550055000000000000005500550000000000000990990999999000000000063360000777000555555555555555500055500000000000000000000000000
555555550000000044494444444444444444444900000000656565650000000000000000000000000000040000e0000000333300000000004004000000000eee
555555550000000044444444444944444444444455555055066606660899900000899900000899900009900066666666037777300077760004040000000000ee
55555555000000004944444944444449444494446666606665656565889889000889889000889889000a90040666666037bb99730776777000440000000000ee
55555555000000004444444449444444494444446666606666066606999889000999889000999889099009a006e9996037bb9973677777670ff4f9f049000099
555555550000000044449444444494444444444400000000656565659899999099899999099899990a90099006e9996037aeee73777677779f9f4f9f99900949
55555555000000004444444bb44b44b4b444449405555555066606668877889098877889098877884009900006e5956037eeea73555555555555555599499999
5555555500000000494444bb4b4bbb4bbb44444406666666656565659977790009977990009777990009a0000659596003777730555555555555555509994990
555555550000000044444bbbbbbbbbbbbbb494440666666666066606000770000007700000077000004000000066660000333300055555500555555000999900
000000000000000044449b4bb4bbbbbbb44444449999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
0005666666650000494444bb4bb4b44bbbb444444444444400aaa700009aa0000009a00000077900008999000000000000000000000000000000000000000000
005661117166500044444b4b44444444b4444944444444440a99777009a99a000009a00000779a90088988900000000000000000000000000000000000000000
05661ccccc16650044444b4b00000000bb444494444444440a9777a009a99a000009a00000799a90099988900000000000000000000000000000000000000000
5661cc171cc16650444944bb00000000bb944444999999990a7779a009a997000009a00000a99a90998999990000000000000000000000000000000000000000
566cc11111cc665044444b4b00000000b444494444444444077799a009a977000009a00000a99a90988778890000000000000000000000000000000000000000
566c1171111c66504444494b00000000bb44444444444444007aaa00009770000009a000000aa900099779900000000000000000000000000000000000000000
566111ccc117665094444bbb00000000b44444444444444400000000000000000000000000000000000770000000000000000000000000000000000000000000
56671c111c11665044449bbbbbbbbbbbbbb444440000000000000000000000000990099009900990099009900000000000000000000000000000000000000000
56611c1c1c116650494444bb4b44b4b4bb4444440006000000000600000000009889988998899009900990090000000000000000000000000000000000000000
56611c1c1c7166504444444bb44b44b4b44449440006500006056000000000009778888997780009900000090000000000000000000000000000000000000000
56617c111c1166504449444444444444444494440050d660006d0500000000009788888997880009900000090000000000000000000000000000000000000000
566111ccc1176650444444444444499444444944066d05000050d600000000009888888998880009900000090000000000000000000000000000000000000000
566c1171111c66504444494494444444449444940005600000065060000000000988889009880090090000900000000000000000000000000000000000000000
566cc11117cc66509444449444494444444444440000600000600000000000000098890000980900009009000000000000000000000000000000000000000000
5661ccc1ccc166504444444444444444444444440000000000000000000000000009900000099000000990000000000000000000000000000000000000000000
00006555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00065666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00065555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666665600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00660000006650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00566666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00056666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
23333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21313131313131313131313131313141000000000000000000000000000000000000000000004040404000000000000000000000000000000000000040000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000404000000040004040404042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000404040400000004000021242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000404040404040404040031342000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22403232323232323232323232323242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000040000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22323232324040404000400000404042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000404040404000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000323200000040000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000040404040404040000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000000003200003242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22323232323200000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22004000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000004000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22320000003232404032320000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000000000000000042404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22004000000000000000000000004042004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22323232000000000040000032323242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000032323232000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22004000000000000000004000400042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22323232320000000000003232323242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000000000000040000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000000003232323232320000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22404040404040404040000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22323232404040404040000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22404040404040404040403232323242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22404040404040404040400000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23333333333333333333333333333343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000103010000000000008080808080000002010200808080800000000000000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1515151515151515151515151515151510101010101010101010101010101010100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000000000404040404040404040400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000000000004040404040004040404040404040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000404040404040000040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000004040404000404040404040404040404000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000004040400040404040404040404040000000400000000000000000000040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000000000000000000040404040404040400000000040000040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500040404000404000404040404001500000000000000000000000000040000040404040404040404040404040404040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000000000000000004040000000004040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000040000000000000000001500000000000000000000000000000000000000000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000040000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000040400000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161616161616161616161616161600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000c5c500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000c5c500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000c5c500000000000000000000000404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000c5c500000000000000000000040400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000004040000c5c500000000000000000000040000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000040400c5c500000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
220000000000000000000000000404c500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
220000000000c5c5c5c5c5c5c500040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
220000000000c5c5c5c5c5c50000000400040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
220000000000c5000000c5c5000000c500000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
220000000000c500c5c5c5c5000000c500000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000c500c500000000c500000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0010000007100030000710005100041000410005100051000910005100041000410003700027000370001700017000170001700017000670007700087000870009700097000a7000b7001c70024700297002e700
000400001a7401d7402074024720297102f7000b1000b10014100131000f1000e1000f100131001410014100179000f5001150011500189001990019900199001990016900169001590017900189001990019900
__music__
02 41424344

