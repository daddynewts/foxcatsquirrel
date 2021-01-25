pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- foxcatsquirrel
-- by james newton

-- init + variables

function _init()
 cartdata("foxcatsquirrel")
 _initall()
end

function _initall()

 level=0 -- def 0, playground 5
 count=0
 points=0
 addfood=10 -- 7 for instant enemy on l1
 lives=3
 
 init_times()
 
 duckangle=0
 duckapproach=0
 ghostangle=0
 ghostapproach=0
 
 -- sfx
 intro_jingle = 63
 eat_sfx = {14,9}
 death_sfx = 1
 jump_sfx = 0
 slide_sfx = 2
 duck_sfx = 12
 bonus_sfx = 13
 endlevel_sfx = 63
 spring_sfx = 4
 ghost_sfx = 12
 menu_sfx = 10
 balloon_sfx = {13,15}
 shockwave_sfx = 3
 gameover_sfx = 55

 -- music
 music_level1 = 0
 music_level2 = 28
 music_level3 = 11
 music_level4 = 7
 music_level5 = 27
 credits      = 5
 
 function rndb(low,high)
  return flr(rnd(high-low+1)+low)
 end
 
 function init_player()
  player.x=(level*128)+8 --60
  player.y=48 --20
  player.dx=0
  player.dy=0
 end
 
 -- crumbs
 effects = {}

 -- effects settings
 explode_size = 1
 explode_amount = flr(rnd(6))+10
 explode_colours = {9} 
 
 shockwave_size = 5
 shockwave_amount = 1
 shockwave_cooldown = 0
 shockwave_colours = {10,9,8,4,6}
  
 draught={
  x=410,
  y=100,
 }

 fire={
  sp=195,
 }

 splash={
  sp=92,
 }
 
 player={
  sp=1,--165
  x=16, -- default 8
  y=24,-- default 24
  w=8,
  h=8,
  flp=false,
  dx=0, -- means player is not moving at the start
  dy=0,
  max_dx=3.4,	-- default 3
  max_dy=3, -- default 3 or 4.5
  acc=0.2, -- was 0.5, now .2
  boost=0,--3.8, -- was 4, now 3.8
  minboost=1,
  maxboost=3.8,
  anim=0,
  holding=false,
  holdtime=0,
  running=false,
  jumping=false,
  falling=false,
  sliding=false,
  landed=false,
  waslanded=0,
  gliding=false,
  dead=false,
  }

 is_shockwave=false

 cam_x=level*128
 cam_y=0
  
 init_platforms()

 init_menu()
 
 sky={}
  sky.x0=0
  sky.y0=0
  sky.x1=1024
  sky.y1=128
 
 clouds={}
  cloud2={x=rnd(flr(10))+60,speed=0.4}--{x=-12}
  cloud3={x=rnd(flr(10))+90,speed=0.5}

 ship={}
  ship.x=20
  ship.y=66
  ship.sp=192
  
 --enemies={
 ghosts={
  ghost={ ghost_sp=10, x=100, flp=false}
 }
 
 ducks={ 
  duck={ x=70, flp=false }
 }
  
 foods={}
  food={
  x=5,
  y=5,
  h=8,
  w=8,
 }
 
  food_start=26
  food_count=4
  
 twinkle={}
  twinkle.sp=44
  
 bonuses={}
   
 balloons={}
  balloon_sp=61
     
 gravity=0.3
 friction=0.95 -- default 0.85
 
--map limits
 map_start=0
 map_end=128
end

function init_enemies()
	del(balloons,balloon)
 del(foods,food)
 del(ghosts,ghost)
 del(ducks,duck)
 del(bonuses,bonus)
end

function init_times()
 airtime=0
 timecolour=3
 m=0
 glidetime=0
 leveltime=1
 timeleft=127
-- timegain=10
 delay=100
 timededuction=0
 maxtd=0.25 --0.3
 platformtime=0
end
 
function init_platforms()
 -- v for vertical 
 
 vplatform={
  x=226,--56
  y=70,--60
  lsprite=72,--69
  rsprite=74,--71
 }
 
 -- h for horizontal
 hplatform={
  x=340,
  y=60,
  lsprite=36,
  rsprite=37,
 } 
end
-->8
-- update and game loop

--function _update() -- these run in order
--end

function init_menu()
 music(intro_jingle)
 timeleft=127
	del(foods,food)
 del(balloons,balloon)
 del(ducks,duck)
 del(ghosts,ghost)
  _update = update_mainmenu
  _draw = draw_menu
end

function init_game()
 level_food()
 make_balloon()
 make_bonus()
 make_enemies()
 _update = update_game
 _draw = draw_game
end

function livescheck() 
	lives-=1
	if lives>=1 then
	 init_dead()
	else
	 init_gameover()
	end
end

function init_gameover()
 delay=100
 m=0
 music(-1)
 sfx(gameover_sfx)
 _update = update_gameover
 _draw = draw_gameover
end

function update_game()
 update_fx()
 player_update()
 level_gimmicks()
 player_animate()
 collide_food()
 collision_enemies()
 move_enemies()
  if #bonuses>=1 then
   collide_bonus()
   move_bonus()
  end
  if #balloons>=1 then
   move_balloons()
   collide_balloon()
  end
   timecheck()  
  if player.y>=127 then
   livescheck() -- fall down
 end
  if shockwave_cooldown<=60 then
   is_shockwave=false
  end
end

function update_gameover()
	music(-1)
 delay-=1
	if delay<=50 and	btnp(❎) then
	 _initall()
	end
end

function timecheck()
 timegain=count -- default 12
 timeleft-=timededuction
 timededuction=0.1*(count/6) -- default 0.1*(count/6)

 if timeleft >=78 then
  timeleft=78
 end
 if timeleft <= 2 then
  livescheck() --time up  
 end
 if timededuction>=maxtd then
  timededuction=maxtd
 end
end

-->8
-- map collision

function collide_map(obj,aim,flag)
 -- obj = table, needs x,y,w,h
 -- aim = left,right,up,down
 
 -- default is local
  x=obj.x y=obj.y
  w=obj.w h=obj.h
 
 --default is all zeroes
 -- removed "local"
  x1=0 y1=0
  x2=0 y2=0
  
 if aim=="left" then
  x1=x-1 y1=y
  x2=x   y2=y+h-1
  
 elseif aim=="right" then
  x1=x+w-1   y1=y
  x2=x+w y2=y+h-1
  
 elseif aim=="up" then
  x1=x+2   y1=y-1
  x2=x+w-3 y2=y
    
 elseif aim=="down" then
  x1=x+2     y1=y+h
  x2=x+w-3   y2=y+h
 end
 
 ---- test ----
 x1r=x1  y1r=y1
 x2r=x2  y2r=y2
 --------------
 
 -- pixels to tiles
 x1/=8     y1/=8
 x2/=8     y2/=8
 
 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
 end
end
-->8
-- player

function player_update()

 -- spring = flag 4
 if collide_map(player,"down",4) then
   player.dy=-6 -- default 5.2
   player.dx*=player.max_dx
   player.jumping=true
   sfx(spring_sfx,0)
   
 -- spikes = flag 5   
 elseif collide_map(player,"down",5) then
   livescheck()  
 
 -- vent = flag 6 
 elseif collide_map(player,"down",6)
 and player.gliding then
  player.dy-=4 --1
  sfx(slide_sfx,0)
 --  player.jumping=true
 elseif collide_map(player,"down",6) 
  and not player.gliding then
  player.dy-=0.6
  sfx(slide_sfx,0)
 end

 -- physics
 player.dy+=gravity
 player.dx*=friction
 
  -- controls
 if btn(⬅️) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
 end

 if btn(➡️) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
 end
 
 --slide
 if player.running
  and not btn(⬅️)
  and not btn(➡️)
  and player.landed
  and not player.falling
  and not player.gliding
  and not player.jumping
   then
    player.running=false
    friction=0.3
    player.sliding=true
 else
    friction=0.95
 end
 
 -- slide turn to left
 if player.running
  and player.dx>=0
  and player.landed
  and btn(⬅️)
   then
    player.running=false
    player.sliding=true
    sfx(slide_sfx,0)
 end
 
  -- slide turn to right
 if player.running
  and player.dx<=0
  and player.landed
  and btn(➡️)
   then
    player.running=false
    player.sliding=true
    sfx(slide_sfx,0)
  end
 
 if player.sliding
  and not btn(⬅️)
  and not btn(➡️)
   then friction=0.7 
 end
  
 --jump
 if btn(❎)
  and not player.gliding
  and not player.falling
  and not btn(⬇️)
   then
    player.holding=true
   else
    player.holding=false
    player.boost=0
 end
 
 if player.holding
  then
   player.boost+=0.5 --1
 end
 
 if player.boost>=1 
  and player.waslanded>=-1 --4
   then
    player.dy-=player.boost
    player.landed=false
    player.waslanded-=0.5
 end
 
 if player.boost>=1
  and player.waslanded>=-0.5
   then
    sfx(jump_sfx,0)
 end
 
 if player.landed
  and not btn(❎)
   then
    player.boost=0
    player.holdtime=0
 end
 
 -- gliding
 if btn(❎)
 and player.falling
  then
    player.gliding=true
    player.dy/=1.3
    glidetime+=0.2
    player.boost=0
 else if player.falling
  then
    player.gliding=false
    glidetime=0
 end 
 
  -- shockwave 
  if btnp(🅾️) then
   shockwave(player.x,player.y,shockwave_width,shockwave_colours,shockwave_amount)
  end
 end

 -- drop-through
 if collide_map(player,"down",0)
  and player.landed
  and not collide_map(player,"down",4)
  and not collide_map(player,"down",7)
  and btn(⬇️)
   then player.jumping=false
     player.y+=7
  if player.y>110 then player.y=110
 end
 end
 
 -- check collision up and down
 if player.dy>0 then
   player.falling=true
   player.landed=false
   player.jumping=false
    
 	 player.dy=limit_speed(player.dy,player.max_dy)
  
   if collide_map(player,"down",0) then
     player.landed=true
     player.waslanded=0
     player.falling=false
     player.gliding=false
     player.dy=0
     player.y-=((player.y+player.h+1)%8)-1 
          
   ------ test ------
     collide_d="yes"
   else
     collide_d="no"
   -----------------
   
   end
   
 elseif player.dy<0 
 and not player.gliding then
   player.jumping=true
   glidetime=0
 if collide_map(player,"up", 1) then
     player.dy=0
     
   ------ test ------
     collide_u="yes"
   else
     collide_u="no"
   -----------------
     
   end
   
end

-- check collision left and right
 if player.dx<0 then
  player.dx=limit_speed(player.dx,player.max_dx)
    if collide_map(player,"left",1) then
     player.dx=0
     
   ------ test ------
     collide_l="yes"
   else
     collide_l="no"
   -----------------
   end
 elseif player.dx>0 then
 
   player.dx=limit_speed(player.dx,player.max_dx)
   
   if collide_map(player,"right",1) then
     player.dx=0
     
     ------ test ------
     collide_r="yes"
   else
     collide_r="no"
   -----------------
   end
 end
 
 --stop sliding
 if player.sliding then
   if abs(player.dx)<.2
   or player.running then
     player.dx=0
     player.sliding=false
   end
 end
 
 player.x+=player.dx
 player.y+=player.dy
  
 --limit player to map
 if player.x<cam_x then
   player.x=cam_x
 end
 if player.x>=cam_x+120 then
  player.x=cam_x+120
 end
 
 if player.y<1 then
    player.y=1
 end
end
  
function player_animate()
 if player.jumping then
   player.sp=7
 elseif player.gliding then
   player.sp=7
 elseif player.falling then
  player.sp=8
 elseif player.sliding then
   player.sp=9
 elseif player.running then
   if time()-player.anim>.1 then
      player.anim=time()
      player.sp+=1
      if player.sp>6 then
        player.sp=3
 --  end
  end
 end
 else 
 
 --player idle
  
   if time()-player.anim>.3 then
      player.anim=time()
      player.sp+=1
      if player.sp>2 then
        player.sp=1
      end
   end
 end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
-->8
	-- draws

function draw_game()
 cls()
 pal()
 cam_x=(level*128)
 cam_y=0
 camera(cam_x,cam_y)
 rectfill(sky.x0,sky.y0,sky.x1,sky.y1,sky.colour) 
 draw_levels()
 map(flr(cam_x/8), flr(cam_y/8), -- upper left map square
  flr(cam_x/8)*8, flr(cam_y)*8, -- world coordinate to draw to
  17,17)   -- 17 because the camera may not be exactly on a map square
 draw_platforms() 
 spr(player.sp,player.x,player.y,1,1,player.flp)
 draw_splashes()
 draw_food()
 draw_fx()
 draw_bonus()
 draw_ui()
 draw_ghost()
 draw_duck()
 draw_balloon()
end

function draw_ui()

 if timeleft>=40 then 
  timecolour=3
 else if timeleft<=18 then
  timecolour=8
 else
  timecolour=9
 end
 end
   
 -- black bg
 rectfill(1+cam_x,119,127+cam_x,127,0)

 -- time box
 rectfill(2+(cam_x),121,timeleft+(cam_x),125,timecolour)
 
 print("time",2+(cam_x),121,7)
 
 -- dividing line
 line((cam_x)+79,119,(cam_x)+79,126,7)
 
 -- score bg (lower right)
 print("score:"..flr(points),(cam_x+81),121,7)
 
 -- ui - white outline
 rect((cam_x),119,(127+(cam_x)),127,7)
  
end

function draw_clouds()
	cloud2.x+=cloud2.speed
	cloud3.x+=cloud3.speed
	
	--cloud 2
	circfill(cloud2.x+2,16,2,7)
	line(cloud2.x,16,cloud2.x+4,16,7)
	line(cloud2.x,17,cloud2.x+6,17,7)
	line(cloud2.x-1,18,cloud2.x+7,18,7)

 -- cloud 3
 circfill(cloud3.x,24,2,7)
 circfill(cloud3.x+5,23,2,7)
 line(cloud3.x-3,25,cloud3.x+9,25,7)
 line(cloud3.x-5,26,cloud3.x+11,26,7)
 
 if cloud2.x>cam_x+168 then
   cloud2.x=cam_x-(rnd(flr(20)))
   cloud2.y=rnd(flr(20))
  elseif cloud3.x>cam_x+200 then
   cloud3.x=cam_x-(rnd(flr(20)))
   cloud3.y=rnd(flr(5))+20
 end
 
 -- boat
 ship.x+=0.15
 if ship.x>=70 then
  ship.x=-100
 end
end
 
function draw_splashes()

 -- level 3
 rectfill(304,114,328,134,1)
 spr(splash.sp,304,110)
 spr(splash.sp,312,110)
 spr(splash.sp,320,110)

 -- level 5
 spr(splash.sp,536,110)
 spr(splash.sp,544,110)
 spr(splash.sp,600,110)
 spr(splash.sp,608,110)
     
 splash.sp+=0.5
  if splash.sp==96 then
     splash.sp=92
  end
end
-->8
-- gimmicks

function level_gimmicks()

 leveltime+=0.01
 shockwave_cooldown-=1
 
 -- moving platform: ⬆️+⬇️
 vplatform.y+=1.4*cos(leveltime)--2*cos(t())
   
 if vplatform.y > player.y --4
 and vplatform.y < player.y+10 -- +12
  and vplatform.x > player.x-12 -- -15
  and vplatform.x < player.x+6
  and player.dy>=0
   then player.vplatform=true
   else player.vplatform=false
  end
  
  if player.vplatform==true then
    player.y=vplatform.y-8
    player.dy=0
    player.landed=true
    player.falling=false
    player.gliding=false
    player.waslanded=0
  end
 
 -- moving platform: ⬅️+➡️  
 hplatform.x+=2*sin(leveltime)
  
 if  hplatform.y > player.y -- -4
  and hplatform.y < player.y+10 -- +4
  and hplatform.x > player.x-12 -- 4
  and hplatform.x < player.x+8
   and player.dy>0
   then player.hplatform=true
  else player.hplatform=false
 end
 
 if player.hplatform==true
  then
    player.y=hplatform.y-8
    player.x+=2*sin(leveltime)
    player.dy=0
    player.landed=true
    player.falling=false
    player.gliding=false
    player.waslanded=0
 end
end

function draw_platforms()
 spr(vplatform.lsprite, vplatform.x,vplatform.y)
 spr(vplatform.rsprite, vplatform.x+8,vplatform.y)
 
 spr(hplatform.lsprite,hplatform.x,hplatform.y)
 spr(hplatform.rsprite,hplatform.x+8,hplatform.y)
end
-->8
-- grabbables

function level_food()
 
  if level==0 then
    for i=1,1 do    
     food={
      sprite=flr(rnd(food_count)+food_start),
      x=flr(rnd(100)+8),
      y=flr(rnd(60)+26),
    }
    add(foods,food)
    end
 end
  
 if level==1 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(100)+16),
    y=flr(rnd(80)+10),
   }
  add(foods,food)
 end
 end
 
 if level>=2 and level<=3 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(90)+16),
    y=flr(rnd(50)+25),
   }
  add(foods,food)
  end
 end
 
 if level==4 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(4)+60),
    y=flr(rnd(70)+25),
   }
  add(foods,food)
  end
 end
  
end

function draw_food()
  spr(food.sprite,food.x,food.y)
end


function collide_food()

 for food in all(foods) do
 	
  if  food.y > player.y-8 -- -4
  and food.y < player.y+8 -- +4
  and food.x+4 > player.x -- 4
  and food.x+4 < player.x+8
   then
    add_foodpoints()
    explode(food.x,food.y,explode_size,explode_colours,explode_amount)
   end
  end
end

function add_foodpoints()
 points+=100+(20*level)+10*flr(glidetime)
 timeleft+=timegain
 count+=addfood
 del(foods,food)
 sfx(rnd(eat_sfx),1)
 crumb=pget(food.x+3,food.y+3)
 init_game()
end
 
function make_bonus()

 if count==10 then
  for i=1,1 do    
   bonus={
    sprite=14,
    x=60+(cam_x),
    y=22,
   }
  add(bonuses,bonus)
  end
 end
end

function move_bonus()
 bonus.y-=0.15*cos(leveltime)
end

function collide_bonus()
    
  for bonus in all(bonuses) do
   if  bonus.y > player.y-8
   and bonus.y < player.y+8
   and bonus.x+4 > player.x
   and bonus.x+4 < player.x+8 then
     points+=100
     del(foods,food)
     del(bonuses,bonus)
     del(ghosts,ghost)
     del(ducks,duck)
     sfx(endlevel_sfx,0)
     init_levelover()
  end
 end
end

function draw_bonus()
 
 for bonus in all(bonuses) do
  circfill(bonus.x+3,bonus.y+3,7+2*(sin(leveltime)),10)
  circfill(bonus.x+3,bonus.y+3,4,7)
  spr(bonus.sprite,bonus.x,bonus.y)
  spr(twinkle.sp,bonus.x+sin(leveltime),bonus.y)
 end
 
  twinkle.sp+=0.5
   if twinkle.sp>=47
  then twinkle.sp=44
 end

end

function make_balloon()

 if count==flr(rnd(20))+10
 then
--flr(rnd(10)+5) then
  for i=1,1 do    
   balloon={
    sprite=61,
    x=rnd(10)+60,
    y=130,
   }
  add(balloons,balloon)
  end
 end
end

function collide_balloon()
    
  for balloon in all(balloons) do
   if  balloon.y > player.y-8
   and balloon.y < player.y+8
   and balloon.x+4 > player.x
   and balloon.x+4 < player.x+8 then
     points+=1000
     lives+=1
     del(balloons,balloon)
     sfx(balloon_sfx[1],0)
     sfx(balloon_sfx[2],1)
     explode(balloon.x,balloon.y,explode_size,explode_colours,explode_amount)
     crumb=pget(balloon.x,balloon.y)
   end
 end
end

function draw_balloon()
 for balloon in all(balloons) do
  circfill(balloon.x,balloon.y,3,8)
  circ(balloon.x,balloon.y,3,1)
 
 -- highlight
 line(balloon.x+1,balloon.y-2,balloon.x+2,balloon.y,7)
 
 -- low light
 line(balloon.x-1,balloon.y+3,balloon.x-2,balloon.y,2)
 
 -- string
 line(balloon.x,balloon.y+4,balloon.x-(sin(leveltime)),balloon.y+8,7)
 end
end

function move_balloons()
 
 for balloon in all(balloons) do
  balloon.x+=sin(leveltime)
  balloon.y-=1
 end
end
-->8
-- levels

function draw_levels()
 
 -- sunny hills
 if level==0 then
   sky.colour=12 -- light blue
 
  -- sea
  rectfill(0,70,70,127,2)
  rect(-1,70,70,127,1)
  -- bubbles
  pset(rnd(flr(50))+5,rnd((flr(10)))+70,7)
  --island
  spr(193,10,64)
  spr(ship.sp,ship.x,ship.y)
  
  -- hills --
  -- far hill
  circfill(99,134,80,15)
  circ(99,134,80,7) -- outline

  -- mid hill
  circfill(126,154,80,14)
  circ(126,154,80,8) -- outline
  
  -- near hill
  circfill(30,174,90,4)
  circ(30,174,90,5) -- outline
  
  -- sun
  circfill(80,15,8,10)
  
  draw_clouds()
  end
 
 -- jungle
 if level==1 then
  sky.colour=0 --3 -- dark green
  
  vplatform.lsprite=36
  vplatform.rsprite=37  
  
   -- trees
   rectfill(130,0,150,128,1)
   rectfill(136,0,150,128,2)
   
   rectfill(170,0,190,128,1)
   rectfill(174,0,190,128,2)
    
   rectfill(208,0,220,128,1)
   rectfill(212,0,220,128,2)

   rectfill(228,0,242,128,1)
   rectfill(232,0,242,128,2)
  
   rectfill(250,0,262,128,1)
   rectfill(252,0,262,128,2)
    
   -- knots + whorls
   circfill(146,60,2,1)
   circfill(186,30,2,1)
   circfill(238,50,2,1)

   -- tree canopy shadows
   circfill(138,-10,37,1)
   circfill(168,-18,33,1)
   circfill(210,-20,33,1)
   circfill(240,-10,35,1)
   
   -- canopy
   circfill(138,-10,35,3)
   circfill(168,-18,31,3)
   circfill(210,-20,31,3)
   circfill(240,-10,33,3)
  
 end
 
 -- castle outside
 if level==2 then
  
   sky.colour=0 -- black
 
  -- dark clouds
  circfill(266,-10,42-sin(2*leveltime),1)
  circfill(296,-18,38+sin(2*leveltime),1)
  circfill(328,-20,42-sin(2*leveltime),1)
  circfill(368,-10,44+sin(2*leveltime),1)
  -- lighter clouds
  circfill(266,-10,38-sin(2*leveltime),5)
  circfill(296,-18,34+sin(2*leveltime),5)
  circfill(328,-20,38-sin(2*leveltime),5)
  circfill(368,-10,40+sin(2*leveltime),5)
  -- lighter outer clouds
  circfill(266,-10,30-sin(2*leveltime),13)
  circfill(296,-18,26+sin(2*leveltime),13)
  circfill(328,-20,30-sin(2*leveltime),13)
  circfill(368,-10,32+sin(2*leveltime),13)
  -- sea/background
  rectfill(256,70,394,128,1)
  hplatform.lsprite=108
  hplatform.rsprite=110
 end
 
 -- castle inside
 if level==3 then
  pal()
  sky.colour=5
  
  -- door
  circ(448,64,14,13)
  circfill(448,60,14,13)
  circfill(448,64,13,0)

  rectfill(434,64,462,127,0)
  rect(434,64,462,127,13)

  line(435,64,461,64,0)
  
  -- draught
  draught.x+=cos(leveltime)/8
  draught.y-=2
  
  if draught.y<=60 then
   draught.y=100
  end
  
  --left draught 
  pset(draught.x,draught.y,rnd(3)+5)
  pset(draught.x+1,draught.y,6)
  pset(draught.x+2,draught.y,7)
  pset(draught.x+3,draught.y,rnd(3)+5)
   
  -- right draught
  pset(draught.x+72,draught.y,rnd(3)+5)
  pset(draught.x+73,draught.y,rnd(3)+5)
  pset(draught.x+74,draught.y,rnd(3)+5)
  pset(draught.x+75,draught.y,rnd(3)+5)
 end
 
 -- brazier
 fire.sp+=0.5
 if fire.sp>=198 then
  fire.sp=195
 end
  spr(fire.sp,392,69)
  spr(fire.sp,496,69)
 
 -- final level - volcano
 if level==4 then
  pal()
  sky.colour=2
  
  -- dark grey clouds
  circfill(518,-24-sin(t()),48,5)
  circfill(548,-28+sin(t()),44,5)
  circfill(578,-30+sin(t()),46,5)
  circfill(628,-24+sin(t()),48,5)

    -- dark red clouds
  circfill(518,-26-sin(t()),46,2)
  circfill(548,-28+sin(t()),40,2)
  circfill(578,-30-sin(t()),44,2)
  circfill(628,-26+sin(t()),46,2)

  -- red clouds
  circfill(518,-26-sin(t()),42,8)
  circfill(548,-28+sin(t()),36,8)
  circfill(578,-30-sin(t()),40,8)
  circfill(628,-26+sin(t()),42,8)
 
  -- light grey clouds
  circfill(518,-18-sin(t()),30,9)
  circfill(548,-26+sin(t()),30,9)
  circfill(578,-24-sin(t()),30,9)
  circfill(628,-20+sin(t()),30,9)
 
  -- fire bg
  rectfill(512,113,640,128,2)
  line(512,118,640,118,8)
  
  -- pass-through bg
  rectfill(560,16,596,86,1)
 
 end 
end

function level_music()
 if level==0 then
  music(music_level1)
 elseif level==1 then
  music(music_level2)
 elseif level==2 then
  music(music_level3)
 elseif level==3 then
  music(music_level4)
 elseif level==4 then
  music(music_level5)
 elseif level==5 then
  music(credits)
 end
end

-->8
-- menus

function draw_menu()
	cls()
	pal()
	camera(0,0)
 rectfill(0,0,127,127,12)
	draw_levels()
	map(0,0,0,0)

	-- speech bubble
 rectfill(20,16,102,23,0)
	rectfill(21,14,104,22,7)
 rect(21,14,104,22,0) 

 --speech bubble to mouth
 line(24,26,25,22,0)
 line(24,26,28,22,0)

 --fill for bubble arrow
 line(25,22,27,22,7)
 pset(26,23,7)

 print("welcome to my game!",26,16,0)

 -- title box
 rectfill(0,44,127,48,9)
 rectfill(0,49,127,53,4)

 -- title in sprites
 sspr(0,64,56,8,13,36,112,16)
 spr(144,83,35) -- acorn
 rectfill(13,52,114,53,1)
    
 -- feedback bg box
 rectfill(17,102,107,122,0)
 rectfill(19,100,109,120,1)
 rect(19,100,109,120,9)
  
 -- rivets
 pset(21,102,10)
 pset(107,102,10)
 pset(21,118,10)
 pset(107,118,10)
  
 print_centre("press 🅾️ for help",105,15)
 print("⌂",31,112,12)
 print("@foxcatsquirrel",40,112,12)

 spr(player.sp,player.x,player.y)

end

function update_mainmenu()
 delay-=2
 player_animate()
 if btnp(❎) then
  sfx(menu_sfx)
  init_game()
  level_music()
 elseif btnp(🅾️) then
  sfx(menu_sfx)
  _draw = draw_tutorial
  _update = update_tutorial
 end
end

function update_tutorial()
 
 player_animate()

 if btnp(❎) then
  _initall()
  sfx(-1)
  sfx(menu_sfx)
  init_game()
  level_music() 
 end
end

function draw_tutorial()
 camera(0,0)
 rectfill(0,0,127,127,12)
	draw_levels()
	map(0,0,0,0)
 
 spr(player.sp,player.x,player.y)
 
 rectfill(20,16,102,23,0)
 rectfill(21,14,104,22,7)
 rect(21,14,104,22,0) 

 --speech bubble to mouth
 line(24,26,25,22,0)
 line(24,26,28,22,0)

 --fill for bubble arrow
 line(25,22,27,22,7)
 pset(26,23,7)

 print("how to play my game!",24,16,0)

 -- instructions box
 rectfill(17,46,107,95,0)
 rectfill(19,44,109,92,2)
 rect(19,44,109,93,4)
 
 -- shadow
 print("get 10 food:",25,51,0)
 print("get 10 food:",26,50,9) 
 
 -- food sprites
 spr(26,74,48)
 spr(27,82,48)
 spr(28,90,48)
 spr(29,98,48)

 -- shadow
 print("grab key: ",25,59,0)
 -- text
 print("grab key: ",26,58,10)
 spr(14,64,57)
 
 -- shadow
 print("avoid enemies: ",25,67,0)
 -- text
 print("avoid enemies: ",26,66,15)
 spr(12,84,64)
 spr(10,96,64,1,1,true)

 -- shadow
 print("to jump and glide",35,75,0) 
 print("❎",25,75,1)
 print("❎",26,74,9)
  -- text
 print("to jump and glide",36,74,7)

 -- shadow
 print("🅾️",25,83,1)
 print("🅾️",26,82,12)
 print("for force field",35,83,0)
 -- text
 print("for force field",36,82,14)

 -- ready? bg box

 rectfill(17,102,107,122,0)
 rectfill(19,100,109,120,2)
 rect(19,100,109,120,9)
  
 print("ready?",52,105,1)
 print("ready?",53,104,9)
 
 print("❎",55,113,1)
 print("❎",56,112,9)
 
 print("press    to play!",31,113,1)
 print("press    to play!",32,112,7)
end

function update_menu()

 delay-=1
 if delay<60 and btnp(❎) then
  sfx(menu_sfx)
  level_music()
  init_game()
  init_times()
  init_platforms()
  _update=update_game
  _draw=draw_game
 end
end

function init_dead()
 music(-1)
 sfx(death_sfx)
 count=0
 init_enemies()
	init_times()
	init_game()
	init_player()
	init_platforms()
 _update=update_dead
 _draw=draw_dead
end

function update_dead()
	delay-=1
 if delay<60 and btnp(❎) then
  music(-1)
  sfx(menu_sfx)
  level_music()
  _update=update_game
  _draw=draw_game
 end
end

function draw_dead()
 pal()
 circles(1,2,4,13)

 if m>=220 then
 -- double-size "you died"
  rectfill(cam_x,44,cam_x+128,48,9)
  rectfill(cam_x,49,cam_x+128,51,4)
  sspr(32,88,60,8,cam_x+24,36,120,16)

  -- press x to restart
  print_centre("your score:".. points,60,15) 
  print_centre("press ❎ to restart",68,15)

  -- lives left
  spr(1,cam_x+52,92)
  print("X "..lives,cam_x+61,94,1)
  print("X "..lives,cam_x+62,93,7)

 end
end

function init_levelover()
  music(-1)
  init_enemies()
  init_times()
  count=0
  level+=1
  m+=12
  init_player()
  _update = update_menu
  _draw = draw_levelover
  if level==5 then
   _update = update_ending
   _draw = draw_youwin
  end
end

function draw_levelover()
 pal()
 circles(4,9,7,12) 
 
 if m>=220 then
 -- double-size "level over"
  rectfill(cam_x,44,cam_x+128,48,9)
  rectfill(cam_x,49,cam_x+128,51,4)
  sspr(68,64,60,8,cam_x+2,36,120,16)

  print_centre("your score:".. points,60,7) 
  print_centre("press ❎ to continue",68,7)
 
  spr(1,cam_x+52,92)
  print("X "..lives,cam_x+61,94,1)
  print("X "..lives,cam_x+62,93,7)

 end
end

function draw_gameover()
 pal()
 
 circles(9,4,2,0)
  
 if m>=220 then
  
  rectfill(cam_x,34,cam_x+128,49,13)
  rectfill(cam_x,46,cam_x+128,53,5)
  sspr(0,80,44,8,cam_x+20,36,88,16)

  -- with drop shadows!
  print_centre("your score:".. points,60,6)

  print_centre("press ❎ to try again",105,6)
 end
end

function draw_youwin()
 pal()
 
 circles(4,9,7,12)

 if m>=220 then
 --rainbow
 circfill(576,52,30-delay/2,8) 
 circfill(576,52,29-delay/2,9) 
 circfill(576,52,28-delay/2,10) 
 circfill(576,52,27-delay/2,11) 
 circfill(576,52,26-delay/2,3) 
 circfill(576,52,25-delay/2,12) 
 circfill(576,52,24-delay/2,14) 
 circfill(576,52,23-delay/2,2)
 circfill(576,52,22-delay/2,12)

 rectfill(512,45,640,60,10)
 rectfill(512,57,640,64,9)

 rectfill(512,64,640,128,12)
 -- double-size "you win"
 sspr(0,88,32,8,544,47,64,16)

 -- text
 print_centre("score: "..points,70,15)
 
 print_centre("press ❎ to watch credits",105,10)
 
 end
end

function update_ending()
 
 delay-=1
 if delay<60 and btnp(❎) then
  init_times()
  _update=update_credits
  _draw=draw_credits
  level_music()
 end
end

function update_credits()
 m+=0.6 --0.6 feels ok

 --player_update()
 player_animate()
 if btn(❎) then
  m+=2
 end
end

function draw_credits()
 cls()

 rectfill(0,0,128,128,1)

 rectfill(512,136-m,639,140-m,9)
 rectfill(512,141-m,639,143-m,4)

 -- title in sprites
 sspr(0,64,56,8,525,128-m,112,16)
 spr(144,595,127-m) -- acorn

 print("a game by james newton",534,152-m,7)

 print("starring",524,176-m,4)
 print("foxcatsquirrel",548,184-m,9) 
 spr(1,608,181-m)
 
 print("ghost",548,194-m,7)
 spr(10,608,191-m) 
  
 print("bad duck",548,204-m,3)
 spr(12,608,202-m) 
 
 print("food",548,214-m,15)
 sspr(80,8,32,8,584,212-m)  
 
 print("special thanks to",524,232-m,4)
 print("hannah",593,240-m,9)
 print("phil",601,248-m,9)
 print("jess",601,256-m,9)
 print("vicky",597,264-m,9)
 print("nerdyteachers.com",549,272-m,9)
 print("and all players!",554,280-m,9)

 print("feedback welcome!",524,304-m,4)
 print("@foxcatsquirrel",557,312-m,12)
 
 if m>=360 then

  sky.colour=12 -- light blue
  rectfill(512,0,640,128,sky.colour)
  
  -- sea
  rectfill(512,70,582,127,2)
  rect(511,70,582,127,1)
  -- bubbles
  pset(rnd(flr(50))+517,rnd((flr(10)))+70,7)
  --island
  spr(193,522,64)
  
  -- hills
  -- far
  circfill(611,134,80,15) -- far hill
  circ(611,134,80,7) -- far outline

 -- mid hill  
  circfill(638,154,80,14) -- mid hill
  circ(638,154,80,8) -- right outline
  
  -- near hill 
  circfill(542,174,90,4) -- near hill
  circ(542,174,90,5) -- left outline

  --fcs sprite
  spr(7,535,65)
 
  --	shadow
  rectfill(521,52,631,60,0)
 	-- speech bubble to mouth
	 line(542,58,542,66,0)
	 line(543,58,543,65,0)
  line(543,65,550,58,0)
  rect(522,51,632,59,0)
    
  -- speech bubble white fill
  line(544,63,544,58,7)
  line(545,62,545,58,7)
  line(546,61,546,58,7)
  line(547,60,547,58,7)
  pset(548,59,7)
  
  rectfill(523,52,631,58,7)
  
  print("thanks for playing my game!",524,53,0)
   
 -- cinematic black bars
 rectfill(512,0,640,32,0) 
 rectfill(512,96,640,128,0)

   if btnp(❎) then
    _initall()
   end
 end 
end

function print_centre(str,y,c)
 print(str,cam_x+(63-(#str*2)),y,1)
 print(str,cam_x+(64-(#str*2)),y-1,c)
end

function circles(c1,c2,c3,c4)
 m+=10
  circfill(cam_x+64,64,m-40,c1)
  circfill(cam_x+64,64,m-80,c2)
  circfill(cam_x+64,64,m-120,c3)
  circfill(cam_x+64,64,m-140,c4)
end
-->8
-- enemies

function make_enemies()

 if count==7 and level==0 then
  make_duck()
 elseif count==5 and level==1 then
  make_duck()
 elseif count==4 and level==2 then
  make_ghost()
 elseif count==2 and level==3 then
  make_ghost()
 elseif count==1 and level==4 then
  make_ghost()
  make_duck()
 end
end

function draw_enemies()
 draw_duck()
 draw_ghost()
end

function move_enemies()
 move_duck()
 move_ghost()
end

function make_duck()
 
 for i=1,1 do
  duck={
    x=cam_x+52,
    y=-10-player.y,
   }
  add(ducks,duck)
  sfx(duck_sfx,0)
  duckchase=true
 end
end

function make_ghost()
 
 for i=1,1 do
  ghost={
   x=cam_x-player.x,
   y=flr(64)-player.y,
   }
  add(ghosts,ghost)
  sfx(ghost_sfx,0)
 end
end

function move_duck() 

 if duckchase==true then
  for duck in all(ducks) do
   duck.x-=((duck.x/100)-(player.x/100))*(player.dx/count+1)
   duck.y-=((duck.y/100)-(player.y/100))*(player.dy/count+1)
  end
 end
end

function move_ghost()

 -- enemy eats food
 for ghost in all (ghosts) do          
  if  food.y > ghost.y-8 --
  and food.y < ghost.y+8 --
  and food.x+4 > ghost.x --
  and food.x+4 < ghost.x+8
    then del(foods,food)
    init_game()
  end
 end
 
  -- ghost moves towards food
  for ghost in all (ghosts) do
   if ghostchase==true then
    ghost.x-=(ghost.x/100)-(food.x/100)
    ghost.y-=(ghost.y/100)-(food.y/100)
   end
  end
end

function collision_enemies()

 for duck in all(ducks) do
 
  if  duck.y > player.y-4
  and duck.y < player.y+4
  and duck.x > player.x-4
  and duck.x < player.x+4 then
      livescheck()  
  end
 end
 
 for ghost in all(ghosts) do
 
  if  ghost.y > player.y-4
  and ghost.y < player.y+4
  and ghost.x > player.x-4
  and ghost.x < player.x+4 then
     livescheck()   
  end
 end
 
 if is_shockwave==true then
  duckapproach=cos(shockwave_x,ducks.duck.y)
  duckangle+=(3.141592654/duckapproach)/180
  
 for duck in all(ducks) do
 
  if  duck.y > shockwave_y-20
  and duck.y < shockwave_y+20
  and duck.x > shockwave_x-20
  and duck.x < shockwave_x+20
   then
    duckchase=false
   end
  end
 end
  if is_shockwave==false then
   duckchase=true
 end
  if duckchase==false then
   duck.x-=cos(duckangle)-(0.25+(duck.x-shockwave_x)/(20+count))
   duck.y-=sin(duckangle)-(0.25+(duck.y-shockwave_y)/(20+count))
 end
 
 if is_shockwave==true then
  ghostapproach=sin(shockwave_x,ghosts.ghost.y)
  ghostangle+=(3.141592654/ghostapproach)/180
 
 for ghost in all(ghosts) do
 
  if  ghost.y > shockwave_y-20
  and ghost.y < shockwave_y+20
  and ghost.x > shockwave_x-20
  and ghost.x < shockwave_x+20
   then
    ghostchase=false
   end
  end
 end
  if is_shockwave==false then
  ghostchase=true
 end
  if ghostchase==false then
   ghost.x-=cos(ghostangle)-(0.25+(ghost.x-shockwave_x)/(20+count))
   ghost.y-=sin(ghostangle)-((ghost.y-shockwave_y)/(20+count))
 end
end

function draw_duck()

 for duck in all(ducks) do
  spr(12,duck.x,duck.y,1,1,duck.flp)
  
  if player.x>=duck.x then
   duck.flp=true
  else
   duck.flp=false
  end
 end
end

function draw_ghost()

 for ghost in all(ghosts) do
  spr(ghost_sp,ghost.x,ghost.y)
   
  if player.x>=ghost.x then
   ghost_sp=10
  else ghost_sp=11
  end
 end
end


-->8
-- effects

function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table)
    local fx={
     x=x,
     y=y,
     t=0,
     die=die,
     dx=dx,
     dy=dy,
     grav=grav,
     grow=grow,
     shrink=shrink,
     r=r,
     c=0,
     c_table=c_table    
    }
    add(effects,fx)
end

function draw_fx()
 for fx in all(effects) do
  --draw pixel for size 1,
  --draw circle for larger
   if fx.r<=1 then
    pset(fx.x,fx.y,crumb)
   else
    circ(fx.x,fx.y,fx.r,fx.c)
    circ(fx.x,fx.y,fx.r+2,fx.c)
   end
 end
end

function update_fx()
	 for fx in all(effects) do
  --lifetime
  fx.t+=2.5 -- size of circle
             -- default = 2.5
 
  if fx.t>fx.die then del(effects,fx) end

  if fx.t/fx.die < 1/#fx.c_table then
     fx.c=fx.c_table[1]

    elseif fx.t/fx.die < 2/#fx.c_table then
     fx.c=fx.c_table[2]

    elseif fx.t/fx.die < 3/#fx.c_table then
     fx.c=fx.c_table[3]

    elseif fx.t/fx.die < 4/#fx.c_table then
     fx.c=fx.c_table[4]

    else
     fx.c=fx.c_table[5]
    end

   --physics
    if fx.grav then fx.dy+=.25 end
    if fx.grow then fx.r+=.8 end
    if fx.shrink then fx.r-=.1 end
  
   --move
    fx.x+=fx.dx
    fx.y+=fx.dy
   end
end

function explode(x,y,r,c_table,num)
 for i=0, num do
  
  --settings
   add_fx(
    x,         -- x
    y,         -- y
    30+rnd(25),-- die
    rnd(2)-1,  -- dx
    rnd(3)-2,  -- dy
    true,     -- gravity
    false,     -- grow
    false,      -- shrink
    r,         -- radius
    c_table    -- color_table
        )
    end
end

function shockwave(x,y,r,c_table,num)
 
 if shockwave_cooldown<=0 then
  for i=0, 1 do
    --settings
    add_fx(
      player.x+3,  -- x
      player.y+3,  -- y
      80,-- die
      0,         -- dx
      0,       -- dy
      false,     -- gravity
      true,     -- grow
      false,      -- shrink
      1, --1       -- starting radius
      c_table    -- color_table
        )
     shockwave_x=(player.x+3)
     shockwave_y=(player.y+3)
     is_shockwave=true
     shockwave_cooldown=100
     sfx(shockwave_sfx)
    end
  else
  end
end
__gfx__
00000000079004007090040007900400709004000790040070900400009004007090040000000000000000000000000000111100000000000000000000000000
00000000049999004099990004999900049999004099990040999900009999004099990070900400000777000007770001333310000000000110000000000000
007007004091910004919100409191000491910004919100409191000091910020919100409999000075750000757500111311310000000019a1111000000000
0007700020f99f0009f99f9020f99f0020f99f0020f99f0020f99f0070f99f0772f99f074091910000777700077777701813813100000000141aaaa100000000
00077000099171907491710709917190799171900991719009917197099171900991719002f99f00077d6d70707d6d0713999331000000001441919100000000
00700700729999070299990072999907029999077299990772999900029999000099990079917190707777070077770019211931000000000110101000000000
00000000009009000090090000900800008008000080090000800800409009000090090000999907007007000070070001999310000000000000000000000000
00000000008008000080080000800000000000000000080000000000780080000008008000080080007007000070070000111100000000000000000000000000
11111111444444441111111144444444011111100122222000000000000000000000000000000000000110000001111000111400011100000000000000000000
bbbbbbbb44444444bbbbbbbb44444445011111100122222000000000000000000000000000000000001ff100001788710187410018e810000000000000000000
23b239bb44444944bc32233b4444444401111110012222200000000000000000000000000000000001ffff10017777f1017f71001e8e10000000000000000000
2222225b4544444433222233494444440111111001222220000000000000000000000000000000001f2ffff117ffff810149410018e810000000000000000000
422422224944444922244222489444440111111001222220000000000000000000000000000000001ffff4f11f78887101949100011171000000000000000000
4444442244444444224944224484444401111110012222200000000000000000000000000000000001f4ff1018877ff100191000000017100000000000000000
44444944444444444444444444445444011111100122222000000000000000000000000000000000001ff1001ffff11000141000000001710000000000000000
44444444444449444444444444444944011111100122222000000000000000000000000000000000000110000111100000010000000000100000000000000000
000000000000000000000000111111110011111111111110000003b0000000000000000000000000000000003000000009000000040000000000000000000000
00000000000000000000000099999999019999999999f941000003b00000000000000000000000b00000000003bbb0009a900000494000000400000000000000
000000000000000000000000449449441944494449449f9100003b00000000000000000000000b0b000000000b3b3b0009000000040000000000000000000000
000000000000000000000000444444441444444444449f9100003b0000000000000000000b00b00b000000000bb3bb0000000000000000000000000000000000
000000000000000000000000444444441444444444449f91000003b00000000000000000b0b0b000000000000b3b3bb000000000000000000000000000000000
000000000000000000000000414441441441441441449f91000003b00000000000000000b00b00000000000000bbb3b000000a00000009000000040000000000
000000000000000000000000441444140144144144144941000003b00000000000000000000b0000000000000000bbb00000a7a000009a900000424000000000
00000000000000000000000011111111001111111111111000003b000000000000000000000b000000000000000000b000000a00000009000000040000000000
00000000000000000000000000000000000000000000000011113b110000000000000000000000000000000300a0a00000000000000000000000000000000000
0000000000000000000000000000000028888888000000009993b999000000000000000000000000000bbb3000aaa00000000000000000000111111111111110
000000000000000000000000000000002888888800000000493b494400000000000000000000000000b3b3b00aa9aa0000000000000000000658888888888560
000000000000000000000000000000002222222228888888443b444400000000000000000000000000bb3bb000a9a00000000000000000000612228888222160
0000000000000000000000000000000000dd550028888888443b44440066550000000000000000000bb3b3b00bb3bb0000000000000000000611112222111160
000000000000000000000000000000000055dd0022222222413b41440228888000000000000000000b3bbb00b00b00b000000000000000000600001111000060
0000000000000000000000000000000000dd550000dd55004413b4140288888000000000000000000bbb0000000b000000000000000000000600000000000060
000000000000000000000000000000000055dd000055dd0011113bb10288888000000000000000000b000000000b000000000000000000000d000000000000d0
11111111111111111111111188887777888877770099aa00000000000000000000111111111111111111110000111111001000001000070000700c0000000c00
1dddddd1ddddddd1ddddddd18888777788887777091dc7a00000000000000000014eeeeeeeeeeeeee8eee710012eeefe00000000007000000c000000c0700000
1d555551d5555551d5555551888877778888777709d17ca0000000000000000014e888ee88e88ee8ee8eee7112eeeeee00000700000000700000000700000007
1d555551d5555551d555555188887777a888777a091dc7a000000000000000001482228e228228828828827112e888ee07000000070707000070000000000700
111111111111111111111111888877779a8877a909d17ca000000000000000001228ff28ff2fe22f22f22fa11282228e00707070c77777700777070007777770
1dddd1dddddd1ddddd1dddd18888777709a87a90091dc7a0000000000000000012fffef2f8fffffffeffffa1142ffe2807777777777c77c7c77777c07777c777
1d5551d555551d55551d555188887777009aa9000091ca000000000000000000012afffffffeffffffaffa101ffafff27c77c7c777777c77777777777c777777
1d5551d555551d55551d555188887777000990000009900000000000000000000011111111111111111111001fffffff77c77c77777777777c777777777777c7
4444444444444444000000000005700007000700000000000000056dd65000000000000000000000000000000000000000100000100008000080090000000900
22222224422222220000000000100700070007000000000000001006600100000000000000000000000000000000000000000000008000000900000090800000
22222224422222220555555000100d0007000700000000000000170dd06100000000000000000000000000000000000000000800000000800000000800000008
1111111111111111000000500001d0000600060000000000000071d00d1700000000000000000000000000000000000008000000080808000080000000000800
000000000000000000000050000570005670567000000000055d00000000d5500000000000000000000000000000000000808080988888800888080008888880
00000000000000000111110000100700567056700000000010d5000000005d010000000000000000000000000000000008888888888988989888889088889888
00000000000000000000000000100d006670566500000000100d00000000d0010000000000000000000000000000000089889898888889888888888889888888
0000000000000000000000000001d000d66166650000000071d0000000000d170000000000000000000000000000000088988988888888888988888888888898
6767676733333333000000000000000000111100000000000122244000000000001111000000000000000000000000000666d66d666666d6666666d000000000
d6d6d6d62332323300044000000004440183331000000000011222400000000001eb381000000000000000000000000066666666666666666d66666600000000
5d5d5d5d2222222300422400dd002222133333810000300001222440000000001e888821000000000000000000000000666ddd66dd6dd66d66d66dd600000000
15151515222225220422224055d222221333333103033300011222400244442018f88f210000000000000000000000006dd111d611d11dd1dd1dd11600000000
010101012225222204222240555d222213389331333333300122244000244200188888210000000000000000000000001115551d551551151151151100000000
0000000022222222042222405555022213388331333043330112224000024000018f8210000000000000000000000000112551512555555d5515555100000000
0000000052222222004224005550000001333310040040400122244000024000001821000000000000000000000000001555d555555515555555d55100000000
00000000222222520004400000000000001442000400004012222244000240000001100000000000000000000000000001111111111111111111111000000000
00000000000000000000000001155dd0dddddddd4444444444444444000240000001100000011110001114000111000000000000155555550000000000000000
000000000000000000000000015555d055d555d5222222222222222200024000001ff100001788710187410018e8100000000000155555550000000000000000
00000000000000000000000001155dd05d555d5522222222222222220002400001ffff10017777f1017f71001e8e100000000000155d55550000000000000000
000000000000000000000000015555d0555555551111d11111111111000240001f2ffff117ffff810149410018e8100000000000155555450000000000000000
00000000000000000000000001155dd0551555150005600000000000000240001ffff4f11f788871019491000111710000000000155555550000000000000000
000000000000000000000000015555d05155515500100600000000000002400001f4ff1018877ff1001910000000171000000000125555550000000000000000
00000000000000000000000001155dd01111111100100d000000000000024000001ff1001ffff110001410000000017100000000155555550000000000000000
000000000000000000000000015555d0111111110001d0000000000000024000000110000111100000010000000000100000000015555d550000000000000000
01111100000000000000011100000000000000000000000011100000000000000000000001100000000000001100001110000000000000001000001000001000
1197711000000000000001710111100000000000000000001710000000000000000000001ff10000000000001f1001fff100000000000001f10001f10001f100
19997710000000000000017111771000000007000000000017100000000000000000000019911111111111111910199991111111111111119111199911119100
1991111111110111111116771a11111111111111111111111a100000000000000000000019911fff1f1f1fff19101991111ff1ff1f11fff191fff191fff19100
1999119a191a1177117711611aaa11aa1a1a1a1aa1aa1aaa1a100000000000000000000019911919191919191910199111919191919191919191919191911100
14911419119116111617116111191919191919191191191919100000000000000000000019991991199119911910019991991191919199119199119199119100
14411441141916661667716114411444144114141141144114100000000000000000000001111111111111111100001111111111111191111111111111111000
11111111111111111111111111111114111111111111111111100000000000000000000000000000000000000000000000000000000010000000000000000000
0000000000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000011000c0000c00b0000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00014910c00cc00cb00bb00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00144491c0c0000cb0b0b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013bbb1c0c0000cb0bbb00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013bbb1c00cc00cb0b0b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000133100c0000c00b0000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01fff1000000000000000001fff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19999100000000000000001991910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14411111111111111111001441411111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14414114411441411444101441414141444144100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12212121211212121212101221212121212121111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01222122121212121221000122112211221121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111111111111110000011111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000000000000110001000000010001010000000000001100000000000100000000000000000000000000000000000000000000000000000000000000000
01717100000000001171017110000171017171000000000017710010000001710000000000000000000000000000000000000000000000000000000000000000
17717100000000001771017171000171177171000000000017771171000001710000000000000000000000000000000000000000000000000000000000000000
199191011010100019911191101101911ee1e101101010001ee1e110111001e10000000000000000000000000000000000000000000000000000000000000000
0199911991919100199191919199119101eee11ee1e1e1001ee1e1e1eee11ee10000000000000000000000000000000000000000000000000000000000000000
001191919191910019991991919191100011e1e1e1e1e1001eeee1e1e1e1e1e11111110000000000000000000000000000000000000000000000000000000000
00014144114410001144141141414141000181881188100018881181881188818181810000000000000000000000000000000000000000000000000000000000
00011011001100000110110010101010000010110011000001110010110011111111110000000000000000000000000000000000000000000000000000000000
0000000000000000005555500003000000003000003000000ddd5dd5dddddd5ddddddd5008800000000000000000000000000000000000000000000000000000
000070000000000005dd0005000330000000300000300000ddddddddddddddddd5dddddd020880e0000000000000000000000000000000000000000000000000
000077000000f00000000000000333000003330000333000ddd555dd55d55dd5dd5dd55d02400ee0000000000000000000000000000000000000000000000000
00077770000eef0000055d000033b3300033b300033b3300d551115d115115515515511d020000e0000000000000000000000000000000000000000000000000
0005777000eeff7000555d60033bbb30033bb33003bbb33011155515551551151151151102244ee0000000000000000000000000000000000000000000000000
00500050042eef4403355d3303bbbb3003bbbb3003bbbb3011255151255555555515555102244ee0000000000000000000000000000000000000000000000000
02444440f444444f4333333403377330033993300339933015555555555515555555555102211ee0000000000000000000000000000000000000000000000000
002244000ffffff00444444000333300003333000033330001111111111111111111111002211ee0000000000000000000000000000000000000000000000000
011111111111111111111110ffffffff0000700004ff0000000000001555555104ff000000000100000000000000000000000000000000000000000000000000
1eee8ee8eeeeee8eeeeef771ffffff4e000770002499f00000000000155555512499f00000001000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee8eeeff7ffffffff007677002449f00000077000155555512449f00000010000000000000000000000000000000000000000000000000000
eee888ee88e88ee8ee8ee88ff9ffffff067766700244000000d66700155555510244000000101000000000000000000000000000000000000000000000000000
e882228e2282288288288224f49fffff0767777000000000005d6700155555510000000000100100000000000000000000000000000000000000000000000000
7228ff28ff2fe22f22f22f4fff4fffff0676667000000000005dd700125555510000000001000010000000000000000000000000000000000000000000000000
fffffef2f8fffffffeffffffffffefff006777600000000000055000155555510000000001000000000000000000000000000000000000000000000000000000
fffafffffffeffffffafffff6ffff9ff00066600000000000000000015555d510000000000000000000000000000000000000000000000000000000000000000
1fffffff0000000000000000000000000000000000000000000000000ddd5dd5dddddd5000000000000000000000000000000000000000000000000000000000
1ffffff1000000000000000000000000000000000000000000000000ddddddddd5dddddd00000000000000000000000000000000000000000000000000000000
1fffffff000000000000000000000000000000000000000000000000ddd555dddd5dd55d00000000000000000000000000000000000000000000000000000000
14ffffff000000000000000000000000000000000000000000000000d551115d5515511d00000000000000000000000000000000000000000000000000000000
1f4fffff000000000000000000000000000000000000000000000000111555151151151100000000000000000000000000000000000000000000000000000000
1fffffff000000000000000000000000000000000000000000000000112551515515555100000000000000000000000000000000000000000000000000000000
1fff1fff000000000000000000000000000000000000000000000000155555555555555100000000000000000000000000000000000000000000000000000000
1ffff4ff000000000000000000000000000000000000000000000000011111111111111000000000000000000000000000000000000000000000000000000000
00111111111111111111111000000000000000000000000000000000000000000000000000770000000000000000000000000000000000000000000000000000
012eeefeefeeefeee8e777710000000000000000000000000000000000000000000000001d667000000000000000000000000000000000000000000000000000
12eeeeeeeeeeeeeeeeeeeff70000000000000000000000000000000000000000000000001dd67000000000000000000000000000000000000000000000000000
12e888ee88e8eee8ee8ee88700000000000000000000000000000000000000000000000001dd0000000000000000000000000000000000000000000000000000
1282228e228288828828822700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
142ffe28f82f222f22f22ff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1ffafff2fffeffffffaffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1ffffffffffffffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc777cccccccccccccc
ccccccccccccccccccccc077777777777777777777777777777777777777777777777777777777777777777777777777777777770ccccc77777ccccccccccccc
cccccccccccccccccccc0077770007000770070007777700070007700700070077000777770007700700070007700700777077770ccccc77777ccccccccccccc
cccccccccccccccccccc0077770777070707777077777707070707077707070707077777770707077770777077070707077077770ccccc7777777ccccccccccc
cccccccccccccccccccc0077770077000700077077777700070077077700070707007777770007077770777077070707077077770cccc777777777cccccccccc
cccccccccccccccccccc0077770777070777077077777707070707077707070707077777770707077770777077070707077777770ccccccccccccccccccccccc
cccccccccccccccccccc0077770777070700777077777707070707700707070007000777770707700770770007007707077077770ccccccccccccccccccccccc
cccccccccccccccccccc0077777777777777777777777777777777777777777777777777777777777777777777777777777777770ccccccccccccccccccccccc
cccccccccccccccccccc0000077700000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccc
cccccccccccccccccccc00000070000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccc
cccccccccccccccc7c9cc4ccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc4c9999cc00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc49191cc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc9f99f9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc749171c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc29999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc9cc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc8cc8cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc11111111111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111cc
c14eeeeeeeeeeeeee8eee71cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc14eeeeeeeeeeeeee8eee71c
14e888ee88e88ee8ee8eee71cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc14e888ee88e88ee8ee8eee71
1482228e2282288288288271cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1482228e2282288288288271
1228ff28ff2fe221111111111cccccccccccccccccccccccccccccc111111cccccccccccccccccccccccccc11ccccccccccccccc1228f111111fe22f22f22fa1
12fffef2f8fffff1111111111cccccccccccccccccccccccccccccc111111ccccccccccccccccccccccccc1491cccccccccccccc12fff111111ffffffeffffa1
c12afffffffef11119977771111cccccccccccccccccccccccccccc117711cc11111111cccccccccccccc144491cccccccccccccc12af117711effffffaffa1c
cc1111111111111119977771111cccccccccccccccccccccccccccc117711cc11111111cccccccccccccc13bbb1ccccccccccccccc11111771111111111111cc
ccccccccccccc11999999777711cccccccccccccccccccccccccccc1177111111777711cccccccccccccc13bbb1cccccccccccccccccc117711ccccccccccccc
ccccccccccccc11999999777711cccccccccccccccccccccccccccc1177111111777711ccccccccccccccc1331ccccccccccccccccccc117711ccccccccccccc
ccccccccccccc119999111111111111111111cc111111111111111166777711aa1111111111111111111111111111111111111111111111aa11ccccccccccccc
ccccccccccccc119999111111111111111111cc111111111111111166777711aa1111111111111111111111111111111111111111111111aa11ccccccccccccc
999999999999911999999111199aa119911aa11117777111177771111661111aaaaaa1111aaaa11aa11aa11aa11aaaa11aaaa11aaaaaa11aa119999999999999
999999999999911999999111199aa119911aa11117777111177771111661111aaaaaa1111aaaa11aa11aa11aa11aaaa11aaaa11aaaaaa11aa119999999999999
99999999999991144991111441199111199111166111111661177111166111111119911991199119911991199119911119911119911991199119999999999999
99999999999991144991111441199111199111166111111661177111166111111119911991199119911991199119911119911119911991199119999999999999
99999999999991144441111444411114411991166666611666677771166111144441111444444114444111144114411114411114444111144119999999999999
44444444444441144441111444411114411991166666611666677771166111144441111444444114444111144114411114411114444111144114444444444444
44444444444441111111111111111111111111111111111111111111111111111111111111144111111111111111111111111111111111111114444444444444
44444444444441111111111111111111111111111111111111111111111111111111111111144111111111111111111111111111111111111114444444444444
44444444444441111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111114444444444444
44444444444441111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111114444444444444
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc12affffffaffa1cccccccccccccccccccc7777772211ee77777cccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111cccccccccccccc7777777ffffff2211eefffff7777777ccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777fffffffffffffffffffffffffffffff7777ccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777fffffffffffffffffffffffffffffffffffffff7777ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777fffffffffffffffffffffffffffffffffffffffffffffff777cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777fffffffffffffffffffffffffffffffffffffffffffffffffffff77
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccccccccccccccfcccccccccccccccccccccccccccccccccccccccccc7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccccccccccccceefcccccccccccccccccccccccc7cccccccccccccc77fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cccccccccccceeff7ccccccccccccccccccccccc77cccccccccccc7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccccccccccc42eef44ccccccccccccccccccccc7777ccccccccc77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
1111111111f444444f1111111111111111111115777111111117ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
22222222222ffffff2222222222222222222225222522222227fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
222222222222222222222222222222222222224444111111111111ffffffffffffffffffff111111111111ffffffffffffffffffffffffffffffffffffffffff
2222222222222222222222222222222222222222414eeeeee8eee71ffffffffffffffffff14eeeeee8eee71fffffffffffffffffffffffffffffffffffffffff
222222222222222222222222222222222222222214e888eeee8eee71ffffffffffffffff14e888eeee8eee71ffffffffffffffffffffffffffffff8888888888
22222222222222222222222222222222222222221482228e88288271ffffffffffffffff1482228e88288271fffffffffffffffffffffff8888888eeeeeeeeee
22222222222222222222222222222222222222221228ff2822f22fa1ffffffffffffffff1228ff2822f22fa1fffffffffffffffffff8888eeeeeeeeeeeeeeeee
222222222222222222222222222222222222222212fffef2feffffa1ffffffffffffffff12fffef2feffffa1fffffffffffffff8888eeeeeeeeeeeeeeeeeeeee
2222222222222222222222222222222222227222212affffffaffa1ffffffffffffffffff12affffffaffa1fffffffffffff888eeeeeeeeeeeeeeeeeeeeeeeee
222222222222222222222222222222222222222227111111111111ffffffffffffffffffff111111111111fffffffffff888eeeeeeeeeeeeeeeeeeeeeeeeeeee
22222222222222222222222222222222222222227ffffffffffffffffffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
2222222222222222222222222222222222222227fffffffffffffffffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
222222222222222222222222222222222222227ffffffffffffffffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
22222222222222222222222222222222222227fffffffffffffffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
2222222222222222222225555555555555555555fffffffffffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
22222222222222555555544444444444444444445555555ffffffffffffffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
2222222225555544444444444444444444444444444444455555ffffffffffffffffffffffffffffffff8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
2222225554444444444444444444444444444444444444444444555fffffffffffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
22111111111111111111114444444444444444444444444444444445555ffffffffffffffffffffff8eeeeeeeeeeeeeeeeeeeeeeee11111111111111111111ee
514eeeeeeeeeeeeee8eee7144444444444444444444444444444444444455ffffffffffffffffff88eeeeeeeeeeeeeeeeeeeeeeee14eeeeeeeeeeeeee8eee71e
14e888ee88e88ee8ee8eee714444444444444444444444444444444444444555ffffffffffffff8eeeeeeeeeeeeeeeeeeeeeeeee14e888ee88e88ee8ee8eee71
1482228e2282288288288271444444444444444444444444444444444444444455fffffffffff8eeeeeeeeeeeeeeeeeeeeeeeeee1482228e2282288288288271
1228ff28ff2fe22f22f22fa1444444444444444444444444444444444444444444555ffffff88eeeeeeeeeeeeeeeeeeeeeeeeeee1228ff28ff2fe22f22f22fa1
12fffef2f8fffffffeffffa144444444444444444444444444444444444444444444455fff8eeeeeeeeeeeeeeeeeeeeeeeeeeeee12fffef2f8fffffffeffffa1
412afffffffeffffffaffa1444444444444444444444444444444444444444444444444558eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee12afffffffeffffffaffa1e
441111111111111111111144444444444444444444444444444444444444444444444444455eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111111111111ee
4444444444444444444444444444444444444444444444444444444444444444444444444445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
444444444444444444444444444444444444444444444444444444444444444444444444444455eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
4444444444444444444444444444444444444444444444444444444444444444444444444444445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
444444444444444444444444444444444444444444444444444444444444444444444444444444455eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
44444444444444444449999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999eeeeeeeeeeeeeeeeee
44444444444444444449111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeeeeeeeeee
444444444444444440091a1111111111111111111111111111111111111111111111111111111111111111111111111111111111111a19eeeeeeeeeeeeeeeeee
44444444444444444009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeeeeeeeeee
44447444444444444009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeeeeee7eee
44477444444444444009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeeeee77eee
44767744444444444009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeeee7677ee
46776674444444444009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeee677667e
4767777444444444400911111111111ccc11111111c11ccc11cc1c1c11cc1ccc1ccc11cc11c11c1c1ccc1ccc1ccc1ccc1c111111111119eeeeeeeeeee767777e
467666744444444440091111111111ccccc111111c1c1c111c1c1c1c1c111c1c11c11c111c1c1c1c11c11c1c1c1c1c111c111111111119eeeeeeeeeee676667e
44677764444444444009111111111ccccccc11111c1c1cc11c1c11c11c111ccc11c11ccc1c1c1c1c11c11cc11cc11cc11c111111111119eeeeeeeeeeee67776e
444666444444444440091111111111c1c1c111111c111c111c1c1c1c1c111c1c11c1111c1cc11c1c11c11c1c1c1c1c111c111111111119eeeeeeeeeeeee666ee
411111111111111110091111111111c1ccc1111111cc1c111cc11c1c11cc1c1c11c11cc111cc11cc1ccc1c1c1c1c1ccc1ccc111111111911111111111111111e
1eee8ee8eeeeee8ee0091111111111111111111111111111111111111111111111111111111111111111111111111111111111111111198eeeeeee8eeeeef771
eeeeeeeeeeeeeeeee009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119eeeeeeeeeee8eeeff7
eee888ee88e88ee88009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119e888e88ee8ee8ee88f
e882228e228228822009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119822282288288288224
7228ff28ff2fe22ff0091111111111111111111111111111111111111111111111111111111111111111111111111111111111111111192fff2fe22f22f22f4f
fffffef2f8fffffff0091a1111111111111111111111111111111111111111111111111111111111111111111111111111111111111a19fff8fffffffeffffff
fffafffffffefffff009111111111111111111111111111111111111111111111111111111111111111111111111111111111111111119fffffeffffffafffff
fffffffffffffffff009999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999ffffffffffffffffff
ffffff4effffff4ef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff4effffff4effffff4e
fffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffff
f9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9fffffff9ffffff
f49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49ffffff49fffff
ff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffff
ffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefff
6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff6ffff9ff

__gff__
0000000000000000000000002323000003030303000000000300000000000000010100010101000707000000000000000003000012930140400000000000101083838300000000000101010300000000010100002323000023000000000000000303030301000000200000000303030000000302010101000000000000130000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100010101000000030303000100000300000100000000000003000003000083830000000000000003030300000000000000000000000000
__map__
0000000000000000000000000000000000000026000000002600003a00002600000000000000000000000000000040414200004300530000000053004300004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000262b000000002600000000000000000000000000000040414200004300530000000053004300004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000002b00000000002600000000002b0000000000000000000000000000004041420000430053000000005300430000400000000000c6e80000e7c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000003a00000000000000260000000000000000000000000000000000000000004041420000430053000000005300430000400000000000d700000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48494a0000000000000000000048494a000000000000000026000000000000000000000000000000000000000000404142000044005176767676500044000040c7c8000000d700000000d7000000c6c7c74849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000024362500000000002400000000000000000000000000004041425700000000000000000000000056400000000000d700000000d70000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000484a000000c90000000000000000000000000000000000000000000000000000000000000000004041420057000000000000000000005600400000000000c6c8000000c6c7c8000000d7000000000000000000000000c900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000242323250000000000000000000000000000000000000000000000000000404142765000000000000000000000517640c7c8000000d700000000d70000000000d700000000000000000000000000000000000000000000000000000000000000002b0000000000002b00000000002b00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000c200004041420000000000000000000000000000400000000000d700000000d70000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000484a0000484a00000000000000000000000000000000000000000000000000000000000000000000004041426700000000000000000000000067400000000000d700000000d7000000c6c7c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041425038384500000000000045380051400000000000c6e80000e7c80000000000d700000000000000000000000000000000000000000000000000000000000000000000002b0000000000002b00000000
48494a0000000000000000000048494a00000000000024363625000000000024404142000000000000000000404141414200003800000000000000003800004000000000000000000000000000000000d74849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000404142000000000000000000404141414200003800000000000000003800004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d40000000000000000000000000000d400290000540000003c3b000000003c0040414235540000000000543540414141420000370054000000005400370000403500000000000000000000000000003541d40000000000000000000000000000d400000000000000000000000000000000000000000000000000000000000000
d0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2101210121210101210121212101210124041414141420000004041414141414141414141414141414141414141414141c6c7c80000c6c7c7c7c7c80000c6c7c842d0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d261616161616161616161616161616127272727272727272727272727272727
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d313131313131313131313131313131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d40000000000000000000000000000d400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000301000d1341233113331143311533117331193311b3211e32121311263212a3112a315003000e3000030001204132040220400204002040020400204002040020400204002040020400204002040020400204
00100000189751797516975159751497513975139751310617900189001890018900169001590014900169001090015900159000c900179000b900159000a900119000a9000b9000b90000900009000090000903
010600000f61413610166150060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
010c00001445314453144531443314423144231441314413146170040000400004000040000400004000040000400004000040000400004000040000400004000040000400004001240000400004000040000400
0106000013723003042b14100304003042d3040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400000
01100000045301202214032085600000009532000000b532045300050000500085300050009530005000b530045300050000500085300050009530005000b530045301202214032000000b532000000b53200000
01100000205520050021522235420050200502285320050200000000001e5041e5051c5041c50500502005022053200502235422153220522005021c5421c512005000050020004200051c0041c0050000000000
011000000c1433f21512313141152461512313141150c1431231300000246000c1433f2150c1433f2150c1430c1433f21512313141152461512313141150c1431231300000141000c1433f2153f4153f2150c143
0110000000100001001b112001021c1121e112001000010223112231122311500100001000010200102001020010200102231120010221112201121e112181021c1121c1121c1021711217110181001711217110
010a0000101310c141111512d16100101001000010000100001003010000100001000010000100001000010000100001000010033100001000010000100001000010000100001000010000100001000010000100
010600001c52720547235272850728507285071a5071950719507175071650715507155071250712507115071150710507105070f507115070f5071050710507115071250712507135071350713507115070e507
01100000106132a100001002710000100001002510027100001002a1000010022100001002f100001002f100000002f500000002f500245002f500005002f500000002f500000002f500005042f500005002f500
010800002666500005186051a65518605186050e63518605000050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500005
0106000028542285522c5522c5522f5522f5523455234542345323451200500005000050000500005000050000500005000050000500005000050000502000000000000000000000000000000000000000000000
010a00001413112141161513416100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001000010000100
010800000567305631056110000100001000010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100000
010f00001d1221d11018100211221f1101810018121181001d1321c1201d1101f12021110181021d124181021d1221d11018102211221f1101810218124181021d1301c1201d1101f1201d1141d1201d11518102
010f00000c0431d500185000551224615185000551205512055121d5000c5110c512246151850224615185020c0431d5000551221502246151f50204512025100251002512005110051024615246152461500000
010f00001504215020180000c04211020180000c0501800016042150301302015030160401800218054180021d0421c0201a0401c0421f0201d0501c0441d050210401f0301d0201f03024044240302101518002
010f000011712117100c70015712137100c7000c7110c70011712107101171013710157100c702117140c70211712117100c70215712137100c7020c7140c702117101071011710137101171411710117150c702
010e00000c313103030c3130c6150c0000c6000c3130c313176050c6150000000000000001c3151e3152f3252f3152f3152f300247052f705007052f705000000000000000000000000000000000000000000000
010e00002f5642a5522a5152756227512275152555427562275152a5622a5152a5102a5152f5542f5142f5642f514005022f5242f514005022f5242f5142450200500005042f5000050000500005000050000000
010e00001204412032120250b0440b0320b0150f0440f0320f0151204412031120201201517044170150b0340b0210b0150b0140000000000000002f100001002f1002f100241002f100001002f1000010000000
01100000101521011512122141421411518102171321711500100001001e0141e0151c0141c0150010200102171321711514142121320f1220f11510142101121c1001c10020014200151c0141c0150010000100
011000000471204712067120871209712097150b7120b7120b7120b7151e0141e0151c0141c015004020040206722067120373203722087220871204722047120471204715140141401510014100150040015400
010600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c043000000c043000002461324115246230c0430c0430000000000000000c113243140c043000000c113000000c0430000024615000000c0430c0000000000000246252421224625242002421224200
011000000c743007000070000700246150000000700007000c74317700197001b7003111421700311142a7000c743007000e70000700246150c70000700007000c74300700007000070031114246153111400700
010c00000d0320f02212012140221603214022120120f0220d0320f01212022140121602216015120000f0000d0320f02212012140221603214022120120f0220d0320f01212022140121602216015120000f000
01100000105400c14310523150301502004613180301c012105400c143105231503015020046131803004613285250c1431c5231503015020046131803010012105400c143105231503015020046131803004613
011000000f5400c14314523120301202004613140301c0120f5400c1431052312030120202461514030246150f5400c14310523120301202004613140301c0120f5400c143105231203012020246151403024615
01100000000000d0031b5241b5121b5152252422512225150f5002352423512235152052420512205152252422512225151b5241b5121b5152252422512225150f50023525235240000020525205241400022522
011000000f5200c123155441353015020155201802015522105201553210520105441502013542175320c0331555018615150141501015554135421802015544100200c123105401502013564175621802015544
011000000f5220f5221b5121b5121b51522512225122251222515235122351223512205122051220512225220f5220f5251b5121b5120f5122251222512225150f51223512235122351520512205122051522512
01080020005300054200532005120053200512005320051203550035420353203512035320351203532035120555005542055320551205532055120553205512075500753207522075120a5500a5420c5500c542
010800000053000542005320051200532005120053200512035500354203532035120353203512035320351205550055420553205512055320551205532055120355003532035220351202550025420055000542
010800000556405542055320553205520055220552205512035640354203532035320352003522035220351202564025420253202532025200252202522025120756407542075320751200554005320052200512
010800000c04300742007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c70024615077420773207732000233c7050c01300000
010800000c0330a7220a7200a7120c0430a7140a71524000246150874208730087320c0430871408715000000c0430774207730077320c043077120771500000246150374203732027320c0430c0030c0330c003
011000000c00000700007000070000000007000c000240002460003700037000370000000037000c0000000005700057000570000000057000c000000000000007700077000770000000077000c0000000000000
011000000c00000700007000070000000007000c000240002460003700037000370000000037000c000000000c00005700057000570000000057000c0003c7002460003700037000270018700187001f7001f700
010c00001f7421f715007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c7002461503742037320273202732050230c01300000
0108000016030160421603216012160321601216032160121405014042140321401214032140121403214012130401304211040110420f0400f0420e0400e0421305013032130221301216050160421805018042
010800000a5600a5620a5520a5320a5520a5320a5420a52208560085520855208522085520852208552085220756007562055500553203550035320254002522075600756207552075320a5500a5320c5400c522
010800000c04300742007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c70024615037420373203732000233c7050b01317000
011000001e1501e1101e1501e11021150221302212022110000000000020140221301e1401e110000000000023150231102315023110221502313023120231102515025110251502511027150251502512025110
011000001e1501e1101e1501e11021150221302212022110000000000020140221301e1401e110000000000023150231102315023110221502313023120231102515025110251502511022150201502012020110
0110000000000000002a1502a1302a1302a1102a1502a130291202912029110291102715027130271202711025150251102515025110271402513025120251102413024110251302511026140261202715027130
0110000000000000002a1502a1302a1302a1102a1502a130291202912029110291102715027130271202711025150251102515025110231402212020130201101e1301e1201e1101e1101e100000000000000000
0110000006750067100675006710097500a7300a7200a7100a7100a710087400a730067400671006710067100b7500b7100b7500b7100a7500b7300b7200b7100d7500d7100d7500d7100f7500d7500d7200d710
0110000006750067100675006710097500a7300a7200a7100a7100a710087400a730067400671006710067100b7500b7100b7500b7100a7500b7300b7200b7100d7500d7100d7500d7100a750087500872008710
011000002375023720237502373022750227322272222710207202075020720207501e7501e7201e7501e7201c7501c7101c7501c7101b7501b7321b7221b7101972019750197201975017750177301772017710
0110000000700007001e7101e7101e7101e7101e7101e7101d7101d7101d7101d7101b7101b7101b7101b710197101971019710197101b710197101971019710187101871019710197101a7101a7101b7101b710
010f00001746412452124110e4620e4120e4110b4540e4620e4151246412412124101241517454174141746417414004020b4240b413004020b4240b413244020040000400004000040000400004000040000400
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0000231641e1521e1151b1621b1121b115191541b1621b1151e1621e1151e1101e11523154231142316423114001021712417114001021712417114241020010000100001000010000100001000010000100
__music__
01 48450506
00 48450507
00 47054706
00 47450708
02 52450507
02 53450618
01 57551113
00 585c1110
00 595c1310
00 5a5c1012
02 5b5b1311
01 415e2061
01 41421f60
00 41422062
00 41422263
00 41422061
00 41421f5f
02 41422021
01 41422427
00 4142252e
00 41422427
00 41422628
00 41422427
00 4142252e
00 41422425
02 41422826
02 41422c44
02 41422c2d
01 41423033
00 41422f34
00 41423134
02 41423234
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
04 41141516

