pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- foxcatsquirrel
-- by james newton

-- init + variables

function _init()

 level=0 -- def 0, playground 5
 count=0
 points=0
 addfood=1 -- 7 for instant enemy on l1
 is_shockwave=false
 
 init_times()

 skullangle=0
 skullapproach=0
 ghostangle=0
 ghostapproach=0
 
 -- sfx
 intro_jingle = 4
 eat_sfx = {14,9}
 death_sfx = 1
 jump_sfx = 0
 slide_sfx = 2
 skull_sfx = 12
 bonus_sfx = 13
 spring_sfx = 4
 ghost_sfx = 12
 menu_sfx = 10
 balloon_sfx = {13,15}
 shockwave_sfx = 3

 -- music
 music_level1 = 0 
 music_level2 = 1
 music_level3 = 10
 music_level4 = 7
 music_level5 = 25
 credits      = 0
 
 function rndb(low,high)
  return flr(rnd(high-low+1)+low)
 end

 -- crumbs
 effects = {}

 -- effects settings
 explode_size = 1
 explode_amount = flr(rnd(10))+4
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
  x1=392,
  x2=496,
  y=69,
  sp=195,
 }

 splash={
  sp=92,
  x1=48,--304,
  y1=105,
  x2=304,
  y2=110,
  x3=512,
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
  max_dx=3,	-- default 3
  max_dy=3, -- default 3 or 4.5
  acc=0.4, -- default 0.5
  boost=3.8, -- default 4
  anim=0,
  running=false,
  jumping=false,
  falling=false,
  sliding=false,
  landed=false,
  gliding=false,
  dead=false,
  }

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
  cloud1={x=rnd(flr(20))+20,speed=0.2}
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
 
 skulls={ 
  skull={ x=70, flp=false }
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
 friction=0.85
 
--map limits
 map_start=0
 map_end=128
end

function init_times()
 airtime=0
 m=0
 glidetime=0
 leveltime=1
-- timegain=10
 delay=100
 timededuction=0
 maxtd=0.3 --0.7
 platformtime=0
end
 
function init_platforms()
 -- v for vertical 
 
 vplatform={
  x=56,--150
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
 
function test_mode()
-- edit test parameters here
-- not in the main body!
-- sfx(-2)
--music(-1) -- music off
end

function test_ui()
 --print("vplatform.y: "..vplatform.y,cam_x+1,9,7)
 --print("hplatform.x: "..hplatform.x,cam_x+1,17,7)
 --food hitbox
-- if #skulls>=1 then
--   print("flip: "..skull_flp,0,0,1)
 --  print("skull.x: "..flr(skull.x),0,0,1)
 --  print("skull.y: "..flr(skull.y),0,8,1)
--  end
 --if is_shockwave==true then
 -- rect(shockwave_x-20,shockwave_y-20,shockwave_x+20,shockwave_y+20,7)
 --end
 --rect(food.x-20,food.y-20,food.x+24,food.y+24,7)
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
 del(skulls,skull)
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

function init_gameover()
 delay=100
 music(-1)
 sfx(death_sfx)
  _update = update_gameover
  _draw = draw_gameover
end

function update_game()
  test_mode()
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
   init_gameover() -- fall down
 end
  if shockwave_cooldown<=60 then
   is_shockwave=false
  end
end

function update_gameover()
	music(-1)
 delay-=1
	if delay<=50 and	btnp(❎) then
	 _init()
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
  init_gameover() --time up  
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
  w=obj.w  h=obj.h
 
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

 -- sand = flag 2
 if collide_map(player,"down",2) then
   friction=0.5
   player.boost=2
   
 -- ice = flag 3
 elseif collide_map(player,"down",3) then
   friction=1
  -- player.max_dx=4
   
 -- spring = flag 4
 elseif collide_map(player,"down",4) then
   player.dy=-6 -- default 5.2
   player.dx*=player.max_dx
   player.jumping=true
   sfx(spring_sfx,0)
   
 -- spikes = flag 5   
 elseif collide_map(player,"down",5) then
   init_gameover()  
 
-- elseif collide_map(player,"up",5) then
 --  init_gameover()

 -- vent = flag 6 
 elseif collide_map(player,"down",6)
 and player.gliding then
  player.dy-=1
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
  and not player.jumping then
   player.running=false
   player.sliding=true
 end
 
 -- slide turn to left
 if player.running
  and player.dx>=0
  and player.landed
  and btn(⬅️) then
   player.running=false
   player.sliding=true
   sfx(slide_sfx,0)
 end
 
  -- slide turn to right
 if player.running
  and player.dx<=0
  and player.landed
  and btn(➡️) then
   player.running=false
   player.sliding=true
   sfx(slide_sfx,0)
  end
 
 --jump
 if btnp(❎)
 and player.landed 
 and not player.jumping
 and not btn(⬇️)
 then
    player.dy-=player.boost
    player.landed=false
    sfx(jump_sfx,0)
  end
 
 -- gliding
 if btn(❎)
 and player.falling
 then player.gliding=true
      player.falling=false
      player.jumping=false
      player.dy/=1.3
      glidetime+=0.2
 else if player.falling
  then player.gliding=false
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

function make_shockwave()
 
 
 if #skulls==0 then
 end	
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
-- sspr(0,16,9,10,player.x,player.y)
 --draw_waterfall()
 draw_splashes()
 draw_food()
 draw_fx()
 draw_bonus()
 draw_ui()
 draw_ghost()
 draw_skull()
 draw_balloon()
end

function draw_ui()

 test_ui()
  
 -- smaller time background
 rectfill(1+(cam_x),119,79+(cam_x),126,0)
 
 if timeleft>=40 then 
  for i=10,1,-20 do
 -- timeleft-=0.5 
   rectfill(2+(cam_x),121,timeleft+(cam_x),125,3)
  end
 end
 if timeleft<=40 then 
  for i=10,1,-20 do
   rectfill(2+(cam_x),121,timeleft+(cam_x),125,9)
  end
 end
 if timeleft<=15 then 
  for i=10,1,-20 do
   rectfill(2+(cam_x),121,timeleft+(cam_x),125,8)
  end
 end

 print("time",2+(cam_x),121,7)
 
 line((cam_x)+79,119,(cam_x)+79,127,7)
 
  -- score bg (lower right)
 rectfill((cam_x+80),119,127+(cam_x),127,0)
 print("score: "..flr(points),(cam_x+81),121,7)
 
  -- white outline
 rect((cam_x),119,(127+(cam_x)),127,7)
 
 if glidetime>=10 then
  print("glide bonus!",player.x-4,player.y-7,0)
  print("glide bonus!",player.x-4,player.y-8,7)
 end
end	

function draw_clouds()
 cloud1.x+=cloud1.speed
	cloud2.x+=cloud2.speed
	cloud3.x+=cloud3.speed
	
 -- cloud 1 - each line a line
 circfill(cloud1.x+4,4,2,7)
--line(cloud1.x+2,4,cloud1.x+4,4,7) 
 line(cloud1.x,5,cloud1.x+7,5,7)
	line(cloud1.x-2,6,cloud1.x+7,6,7)
	
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

	 if cloud1.x>=cam_x+128 then
	  cloud1.x=cam_x-8
	  cloud1.y=rnd(flr(20))
  elseif cloud2.x>cam_x+168 then
   cloud2.x=cam_x-(rnd(flr(20)))
   cloud2.y=rnd(flr(20))
  elseif cloud3.x>cam_x+200 then
   cloud3.x=cam_x-(rnd(flr(20)))
   cloud3.y=rnd(flr(5))+20
 end
 
 -- boat
 ship.x+=cloud1.speed
 if ship.x>=70 then
  ship.x=-10
 end

 -- sparkles
 
end

function draw_splashes()
 -- level 1
 --spr(splash.sp,splash.x1,splash.y1)
 --spr(splash.sp,splash.x1+8,splash.y1)
 --spr(splash.sp,splash.x1+16,splash.y1)  
 --spr(splash.sp,splash.x1+24,splash.y1)  

 -- level 3
 rectfill(splash.x2,splash.y2+4,splash.x2+24,splash.y2+24,1)
 spr(splash.sp,splash.x2,splash.y2)
 spr(splash.sp,splash.x2+8,splash.y2)
 spr(splash.sp,splash.x2+16,splash.y2)

 -- level 5
-- spr(splash.sp,splash.x3,splash.y2)
-- spr(splash.sp,splash.x3+8,splash.y2)
-- spr(splash.sp,splash.x3+16,splash.y2)
 spr(splash.sp,splash.x3+24,splash.y2)
 spr(splash.sp,splash.x3+32,splash.y2)
-- spr(splash.sp,splash.x3+40,splash.y2)
-- spr(splash.sp,splash.x3+48,splash.y2)
-- spr(splash.sp,splash.x3+56,splash.y2)
-- spr(splash.sp,splash.x3+64,splash.y2)
-- spr(splash.sp,splash.x3+72,splash.y2)
-- spr(splash.sp,splash.x3+80,splash.y2)
 spr(splash.sp,splash.x3+88,splash.y2)
 spr(splash.sp,splash.x3+96,splash.y2)
-- spr(splash.sp,splash.x3+104,splash.y2)
-- spr(splash.sp,splash.x3+112,splash.y2)
-- spr(splash.sp,splash.x3+120,splash.y2)
     
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
 
 if level==1 then
  vplatform.x=226
 else vplatform.x=vplatform.x
 end
 
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
  end
 
 -- moving platform: ⬅️+➡️  
 hplatform.x+=2*sin(leveltime)
-- hplatform.y+=2*cos(leveltime)
  
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
-- bungee
--if level==0 and
-- player.y>=80 then
--  player.dy-= 2
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
    x=level*128+flr(rnd(90)+16),
    y=flr(rnd(80)+15),
   }
  add(foods,food)
 end
 end
 
 if level==2 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(90)+16),
    y=flr(rnd(50)+25),
   }
  add(foods,food)
  end
 end
  
 if level==3 then
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
 --for food in all(foods) do
  spr(food.sprite,food.x,food.y)
 --end
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
 points+=100+10*flr(glidetime)
 -- points+=flr(10000/timeleft)
 timeleft+=timegain
 count+=addfood
 del(foods,food)
 sfx(rnd(eat_sfx),1)
 crumb=pget(food.x+3,food.y+3)
 init_game()
end
 
function make_bonus()

 if count==10 and level<=1 then
  for i=1,1 do    
   bonus={
    sprite=14,
    x=60+(cam_x),
    y=20,
   }
  add(bonuses,bonus)
  end
 end
 
 if count==10 and level==2 then
  for i=1,1 do    
   bonus={
    sprite=14,
    x=54+(cam_x),
    y=rnd(flr(20))+20,
   }
  add(bonuses,bonus)
  end
 end
 
 if count==10 and level>=3 then
  for i=1,1 do    
   bonus={
    sprite=14,
    x=60+(cam_x),
    y=rnd(flr(20))+10,
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
      del(skulls,skull)
      sfx(bonus_sfx,0)
      init_levelover()
  end
 end
end

function draw_bonus()
 
 twinkle.sp+=0.5
   if twinkle.sp>=47
  then twinkle.sp=44
 end
 
 for bonus in all(bonuses) do
  spr(bonus.sprite,bonus.x,bonus.y)
   spr(twinkle.sp,bonus.x+sin(leveltime),bonus.y)
 end
end

function make_balloon()

 if count==flr(rnd(10))+10
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
 -- spr(balloon_sp,balloon.x,balloon.y)
 circfill(balloon.x,balloon.y,3,8)
 circ(balloon.x,balloon.y,3,1)
 -- highlight
 line(balloon.x+1,balloon.y-2,balloon.x+2,balloon.y,7)
 -- low light
  line(balloon.x-1,balloon.y+3,balloon.x-2,balloon.y,2)
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
 -- splash.sp=92
  sky.colour=12 -- light blue
 
  -- sea
  rectfill(0,70,70,127,2)
  rect(-1,70,70,127,1)
  -- bubbles
  pset(rnd(flr(50))+5,rnd((flr(10)))+70,7)
  --island
  spr(193,10,64)
  spr(ship.sp,ship.x,ship.y)
  
  -- hills
  -- cake
   circfill(99,134,80,15) -- far hill
 -- green circfill(99,134,80,15) -- far hill
  circ(99,134,80,7) -- far outline

 -- cake  
  circfill(126,154,80,14) -- mid hill
 -- green circfill(126,154,80,11) -- mid hill
  circ(126,154,80,8) -- right outline
  
  -- cake 
  circfill(30,174,90,4) -- near hill
 -- green circfill(30,174,90,3) -- near hill
  circ(30,174,90,5) -- left outline
  
  circfill(80,16,8,10) -- sun
  
  draw_clouds()
  -- dancing flower
  --spr(30,96,104+flr(sin(leveltime)))
  -- top of base platform
  --line(0,112,128,112,1)
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
--  circ(146,60,3,0)
   circfill(146,60,2,1)
 --  circ(186,30,3,0)
   circfill(186,30,2,1)
   circfill(238,50,2,1)
   --oval(186,30,3,0)
   
      -- outlines
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
   --pal(6,5) -- pale -> dark grey
   --pal(9,4) -- orange -> brown
   --pal(8,2) -- red -> maroon
   --pal(7,13) -- white -> blue-grey
   --pal(11,3) -- pale -> dark green
   --pal(15,4) -- peach -> brown
   --pal(10,2) -- yellow -> maroon
   --pal(12,1) -- pale -> dark blue
   --pal(14,2) -- pink -> maroon
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
  circ(cam_x+64,64,14,13)
  circfill(cam_x+64,60,14,13)
  circfill(cam_x+64,64,13,0)

  rectfill(cam_x+50,64,cam_x+78,127,0)
  rect(cam_x+50,64,cam_x+78,127,13)

  line(cam_x+51,64,cam_x+77,64,0)
  
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
  spr(fire.sp,fire.x1,fire.y)
  spr(fire.sp,fire.x2,fire.y)
 
 -- final level - volcano
 if level==4 then
  pal()
  sky.colour=2
--  circfill(576,100,108,1)
--  circ(576,100,108,2)
--  circfill(576,10,20,0)
--  circ(576,10,20,9)
  
  -- dark grey clouds
  circfill(cam_x+6,-24-sin(t()),48,5)
  circfill(cam_x+36,-28+sin(t()),44,5)
  circfill(cam_x+68,-30+sin(t()),46,5)
  circfill(cam_x+116,-24+sin(t()),48,5)

    -- dark red clouds
  circfill(cam_x+6,-26-sin(t()),46,2)
  circfill(cam_x+36,-28+sin(t()),40,2)
  circfill(cam_x+68,-30-sin(t()),44,2)
  circfill(cam_x+116,-26+sin(t()),46,2)

  -- red clouds
  circfill(cam_x+6,-26-sin(t()),42,8)
  circfill(cam_x+36,-28+sin(t()),36,8)
  circfill(cam_x+68,-30-sin(t()),40,8)
  circfill(cam_x+116,-26+sin(t()),42,8)
 
  -- light grey clouds
  circfill(cam_x+6,-18-sin(t()),30,9)
  circfill(cam_x+36,-26+sin(t()),30,9)
  circfill(cam_x+68,-24-sin(t()),30,9)
  circfill(cam_x+116,-20+sin(t()),30,9)
 
  -- fire bg
  rectfill(512,113,640,128,2)
  line(512,118,640,118,8)
  -- pass-through bg
  rectfill(568,16,588,86,1)
 
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
	rectfill(player.x+5,player.y-10,player.x+88,player.y-2,7)
 rect(player.x+5,player.y-10,player.x+88,player.y-2,0) 

 --pset for rounded corners
 pset(player.x+5,player.y-10,sky.colour)
 pset(player.x+88,player.y-2,sky.colour)
 pset(player.x+5,player.y-2,sky.colour)
 pset(player.x+88,player.y-10,sky.colour)
 
 --speech bubble to mouth
 line(player.x+8,player.y+2,player.x+9,player.y-2,0)
 line(player.x+8,player.y+2,player.x+12,player.y-2,0)

 --fill for bubble arrow
 line(player.x+9,player.y-2,player.x+11,player.y-2,7)
 pset(player.x+10,player.y-1,7)

 print("welcome to my game!",player.x+10,player.y-8,0)

 -- title box
 rectfill(0,44,127,48,9)
 rectfill(0,49,127,53,4)

 -- title in sprites
 sspr(0,64,56,8,13,36,112,16)
 spr(144,83,35) -- acorn
 rectfill(13,52,114,53,1)
    
 -- control bg box
 --rectfill(25,55,103,71,1)
 --rect(25,55,103,71,9)
 
 -- control rivets
 --pset(27,57,10)
 --pset(27,69,10)
 --pset(101,57,10)
 --pset(101,69,10)
 
-- print("start",30,61,7)
 -- print("press    to start",29,61,7)
 -- print("c",57,61,12)
 --circ(58,63,5,12)
 
 -- c sprite
-- spr(112,54,59)
 
-- print("help", 69,61,7)
 --spr(113,91,59)
 ---print("press    for info",29,74,7)
 --print("a",57,74,11)
 -- circ(58,76,5,11)
 
 -- feedback bg box
 rectfill(17,102,107,122,0)
 rectfill(19,100,109,120,1)
 rect(19,100,109,120,12)
  
 -- rivets
 pset(21,102,10)
 pset(107,102,10)
 pset(21,118,10)
 pset(107,118,10)
  
 print("feedback welcome!",31,104,7)
 print("tweet",23,112,12)
 print("@foxcatsquirrel",47,112,9)

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
  _init()
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
 
 rectfill(player.x+5,player.y-10,player.x+88,player.y-2,7)
 rect(player.x+5,player.y-10,player.x+88,player.y-2,0) 

 --pset for rounded corners
 pset(player.x+5,player.y-10,12)
 pset(player.x+88,player.y-2,12)
 pset(player.x+5,player.y-2,12)
 pset(player.x+88,player.y-10,12)
 
 --speech bubble to mouth
 line(player.x+8,player.y+2,player.x+9,player.y-2,0)
 line(player.x+8,player.y+2,player.x+12,player.y-2,0)

 --fill for bubble arrow
 line(player.x+9,player.y-2,player.x+11,player.y-2,7)
 pset(player.x+10,player.y-1,7)

 print("how to play my game!",player.x+8,player.y-8,0)

 rectfill(17,42,107,95,0)
 rectfill(19,40,109,92,2)
 rect(19,40,109,92,4)
 
 -- 16,48 works 
 -- shadow
 print("get 10 food:",25,49,1)
 print("get 10 food:",26,48,7) 
 -- text

 spr(26,74,47)
 spr(27,82,47)
 spr(28,90,47)
 spr(29,98,47)

 -- shadow
 print("grab key: ",25,57,1)
 -- text
 print("grab key: ",26,56,7)
 spr(14,64,54)
 
 -- shadow
 print("avoid enemies: ",25,65,0)
 -- text
 print("avoid enemies: ",26,64,7)
 spr(12,82,62)
 spr(10,92,62)

 -- shadow
 print("press ❎ to jump",25,73,0) 
  -- text
 print("press ❎ to jump",26,72,7)

 -- shadow
 print("hold ❎ to glide",25,81,0)
 -- text
 print("hold ❎ to glide",26,80,7)
-- print("(c)",50,72,12)
-- print("(c)",46,80,12)

 -- ready? bg box

 rectfill(17,102,107,122,0)
 rectfill(19,100,109,120,1)
 rect(19,100,109,120,12)
  
 print("ready?",52,105,2)
 print("ready?",53,104,7)
 print("❎",55,113,2)
 print("❎",56,112,9)
 print("press    to play!",31,113,1)
 print("press    to play!",32,112,7)
-- print("❎",56,114,1)
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

function init_levelover()
  music(-1)
  del(balloons,balloon)
  del(foods,food)
  del(ghosts,ghost)
  del(skulls,skull)
  count=0
  level+=1
  m+=12
  timeleft=127--timeleft+(timegain*2)
  player.x=(level*128)+63
  player.y=16
  player.dx=0
  player.dy=0
  _update = update_menu
  _draw = draw_levelover
  if level==5 then
   _update = update_ending
   _draw = draw_youwin
  end
end

function draw_levelover()
 pal()
  -- full-width stripe
 
 --  rectfill(cam_x,31,cam_x+m,65,10)
 --  rectfill((cam_x+128)-m,32,cam_x+128,64,1)
  m+=12 
  -- circfill(cam_x+64,64,m,2)
  
  circfill(cam_x+64,64,m-40,4)
  circfill(cam_x+64,64,m-80,9)
  circfill(cam_x+64,64,m-120,7)
  circfill(cam_x+64,64,-30+m/3,12)
 -- blue fill
-- rectfill(cam_x,34,cam_x+m,62,sky.colour)
 
 if m>=280 then
 -- double-size "level over"
  rectfill(cam_x,44,cam_x+128,48,9)
  rectfill(cam_x,49,cam_x+128,51,4)
  sspr(68,64,60,8,cam_x+2,36,120,16)

  -- with drop shadows!
  print("your score:".. points,cam_x+33,57,0) 
  print("your score:".. points,cam_x+34,56,7)
  print("press ❎ to continue",cam_x+23,65,0)
  print("press ❎ to continue",cam_x+24,64,7)
  print("❎",cam_x+47,65,4)
  print("❎",cam_x+48,64,9)
 end
end

function draw_gameover()
 pal()
 
 --  rectfill(cam_x,31,cam_x+m,65,10)
 --  rectfill((cam_x+128)-m,32,cam_x+128,64,1)
 m+=12
  circfill(cam_x+64,64,m-40,9)
  circfill(cam_x+64,64,m-80,4)
  circfill(cam_x+64,64,m-120,2)
  circfill(cam_x+64,64,-30+m/3,0)
  
 if m>=280 then
 
  rectfill(cam_x,42,cam_x+128,48,13)
  rectfill(cam_x,49,cam_x+128,52,5)
  sspr(0,80,44,8,cam_x+20,36,88,16)

  -- with drop shadows!
  print("your score:".. points,cam_x+33,57,5) 
  print("your score:".. points,cam_x+34,56,7)
  print("press ❎ to try again",cam_x+21,105,5)
  print("press ❎ to try again",cam_x+22,104,7)
  print("❎",cam_x+45,105,4)
  print("❎",cam_x+46,104,9)
 end
end

function draw_youwin()
 pal()
 
 m+=12
  circfill(cam_x+64,64,m-40,4)
  circfill(cam_x+64,64,m-80,9)
  circfill(cam_x+64,64,m-120,7)
  circfill(cam_x+64,64,-30+m/2,12)

 if m>=280 then
  rectfill(cam_x,44,cam_x+128,48,9)
  rectfill(cam_x,49,cam_x+128,51,4)
 
 -- double-size "you win"
 sspr(0,88,32,8,cam_x+32,36,64,16)

 -- text
 print("score: "..points,cam_x+44,57,1)
 print("score: "..points,cam_x+44,56,7)
 print("press ❎ to watch credits",cam_x+16,105,0)
 print("press ❎ to watch credits",cam_x+16,104,7)
 print("❎",cam_x+40,105,4)
 print("❎",cam_x+40,104,9)
 
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
 level=5
 m+=0.6 --0.6 feels ok

 --player_update()
 player_animate()
 if btn(❎) then
 --  _init()
  m+=3
 end
end

function draw_credits()
 cls()
 rectfill(cam_x,0,cam_x+128,128,1)

 rectfill(cam_x+0,136-m,cam_x+127,140-m,9)
 rectfill(cam_x+0,141-m,cam_x+127,143-m,4)

 -- title in sprites
 sspr(0,64,56,8,cam_x+13,128-m,112,16)
 spr(144,cam_x+83,127-m) -- acorn

 print("a game by james newton",cam_x+22,152-m,7)

 print("starring",cam_x+12,176-m,4)
 print("foxcatsquirrel",cam_x+36,184-m,9) 
 spr(player.sp,cam_x+96,181-m)
 
 print("ghost",cam_x+36,194-m,7)
 spr(10,cam_x+96,191-m) 
  
 print("bad duck",cam_x+36,204-m,3)
 spr(12,cam_x+96,202-m) 
 
 print("food",cam_x+36,214-m,15)
 sspr(80,8,32,8,cam_x+72,212-m)  
 
 print("special thanks to",cam_x+12,232-m,4)
 print("hannah",cam_x+81,240-m,9)
 print("phil",cam_x+89,248-m,9)
 print("jess",cam_x+89,256-m,9)
 print("vicky",cam_x+85,264-m,9)
 print("nerdyteachers.com",cam_x+37,272-m,9)
 print("and all players!",cam_x+42,280-m,9)

 print("feedback welcome!",cam_x+12,304-m,4)
 print("@foxcatsquirrel",cam_x+45,312-m,12)
-- print("followers!",cam_x+44,272-m,9)

 
 if m>=360 then

  sky.colour=12 -- light blue
  rectfill(cam_x,0,cam_x+128,128,sky.colour)
  
  -- sea
  rectfill(cam_x+0,70,cam_x+70,127,2)
  rect(cam_x+-1,70,cam_x+70,127,1)
  -- bubbles
  pset(rnd(flr(50))+cam_x+5,rnd((flr(10)))+70,7)
  --island
  spr(193,cam_x+10,64)
  
  -- hills
  -- cake
  circfill(cam_x+99,134,80,15) -- far hill
 -- green circfill(99,134,80,15) -- far hill
  circ(cam_x+99,134,80,7) -- far outline

 -- cake  
  circfill(cam_x+126,154,80,14) -- mid hill
-- -- green circfill(126,154,80,11) -- mid hill
  circ(cam_x+126,154,80,8) -- right outline
  
  -- cake 
  circfill(cam_x+30,174,90,4) -- near hill
 -- green circfill(30,174,90,3) -- near hill
  circ(cam_x+30,174,90,5) -- left outline

  spr(7,cam_x+24,64)
 	-- speech bubble to mouth
	
  line(cam_x+31,58,cam_x+31,65,0)
  line(cam_x+31,65,cam_x+38,58,0)
  rect(cam_x+10,51,cam_x+120,59,0)
  
  -- speech bubble white fill
  line(cam_x+32,63,cam_x+32,58,7)
  line(cam_x+33,62,cam_x+33,58,7)
  line(cam_x+34,61,cam_x+34,58,7)
  line(cam_x+35,60,cam_x+35,58,7)
  pset(cam_x+36,59,7)
  
  rectfill(cam_x+11,52,cam_x+119,58,7)
  
 --fill for bubble arrow
-- line(player.x+9,player.y-2,player.x+11,player.y-2,7)
-- pset(player.x+10,player.y-1,7)

  print("thanks for playing my game!",cam_x+12,53,0)
 -- rectfill(cam_x,128,cam_x+128,96,0)

 rectfill(cam_x,0,cam_x+128,32,0) 
 rectfill(cam_x,96,cam_x+128,128,0) 

-- spr(182,cam_x+18,52+2*cos(t()))
-- spr(183,cam_x+24,52-2*cos(t()))

   if btnp(❎) then
    _init()
   end
 end 
end
-->8
-- enemies

function make_enemies()

 if count==7 and level==0 then
  make_skull()
 elseif count==5 and level==1 then
  make_skull()
 elseif count==4 and level==2 then
  make_ghost()
 elseif count==2 and level==3 then
  make_ghost()
 elseif count==1 and level==4 then
  make_ghost()
  make_skull()
 end
end

function draw_enemies()
 draw_skull()
 draw_ghost()
end

function move_enemies()
 move_skull()
 move_ghost()
end

function make_skull()
 
 for i=1,1 do
  skull={
    x=cam_x+52,
    y=-10-player.y,
   }
  add(skulls,skull)
  sfx(skull_sfx,0)
  skullchase=true
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
  ghost.orbit=false
 end
end

function move_skull() 

 if skullchase==true then
  for skull in all(skulls) do
-- easy
   skull.x-=((skull.x/100)-(player.x/100))*(player.dx/count+1)
   skull.y-=((skull.y/100)-(player.y/100))*(player.dy/count+1)
  end
 end
end

function move_ghost()
-- enemyapproach=atan2(food.x+4,ghosts.ghost.y)
-- enemyangle+=(3.141592654/enemyapproach)/180
 
 --atan2 gives angle of 
 --two points
 
 --end
  --if ghost.x<=cam_x
  -- then ghost.x=cam_x
  --end
  
  -- enemy eats food
 for ghost in all (ghosts) do          
  if  food.y > ghost.y-8 -- -4
  and food.y < ghost.y+8 -- +4
  and food.x+4 > ghost.x -- 4
  and food.x+4 < ghost.x+8
    then del(foods,food)
    init_game()
  end
 end
 
  -- circular movement
  --for ghost in all (ghosts) do
  -- if ghost.x > food.x-20
  -- and ghost.x < food.x+24
  -- and ghost.y > food.y-20
  -- and ghost.y < food.y+24
  --  then ghost.orbit=true
   -- else ghost.orbit=false
   --end
  --end
  
  -- circular movement!
  for ghost in all (ghosts) do
   if ghostchase==true then
    ghost.x-=(ghost.x/100)-(food.x/100)
    ghost.y-=(ghost.y/100)-(food.y/100)
   end
  end
 --  elseif ghost.orbit==true then
--    ghost.x=food.x-(10*cos(enemyangle))
--    ghost.y=food.y-(10*sin(enemyangle))
  --  ghost.x=food.x-(15*cos(leveltime))
  --  ghost.y=food.y-(15*sin(leveltime))
  -- end
  --end
end

function collision_enemies()

 for skull in all(skulls) do
 
  if  skull.y > player.y-4
  and skull.y < player.y+4
  and skull.x > player.x-4
  and skull.x < player.x+4 then
      init_gameover()  
  end
 end
 
 for ghost in all(ghosts) do
 
  if  ghost.y > player.y-4
  and ghost.y < player.y+4
  and ghost.x > player.x-4
  and ghost.x < player.x+4 then
      init_gameover()  
  end
 end
 
 if is_shockwave==true then
  skullapproach=cos(shockwave_x,skulls.skull.y)
  skullangle+=(3.141592654/skullapproach)/180
  
 for skull in all(skulls) do
 
  if  skull.y > shockwave_y-20
  and skull.y < shockwave_y+20
  and skull.x > shockwave_x-20
  and skull.x < shockwave_x+20
   then
    skullchase=false
   end
  end
 end
  if is_shockwave==false then
   skullchase=true
 end
  if skullchase==false then
   skull.x-=cos(skullangle)-(0.25+(skull.x-shockwave_x)/(20+count))
   skull.y-=sin(skullangle)-((skull.y-shockwave_y)/(20+count))
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
   ghost.x-=((ghost.x-shockwave_x)/(20+count)/2)-cos(2*ghostangle)
   ghost.y-=sin(2*ghostangle)-((ghost.y-shockwave_y)/(10+count))/2
  end
 
end

function draw_skull()

 for skull in all(skulls) do
  spr(12,skull.x,skull.y,1,1,skull.flp)
  
  if player.x>=skull.x then
   skull.flp=true
  else
   skull.flp=false
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
   
    --fx.c=crumb
   
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
11111111444444441111111144444444011111100122222000000000808000000111111000900000000110000001111000111400011100000000000000000000
bbbbbbbb44444444bbbbbbbb44444445011111100122222000000000720200001c3baf2109a90000001ff100001788710187410018e810000000000000000000
23b239bb44444944bc32233b44444444011111100122222000000000249404001dba98f10090000001ffff10017777f1017f71001e8e10000044700000000000
2222225b454444443322223349444444011111100122222000000000449999001ba989a1000000a01f2ffff117ffff810149410018e8100002000400000a0000
42242222494444492224422248944444011111100122222000000000049191001a989ab100000a7a1ffff4f11f788871019491000111710009244f000bb3bb00
4444442244444444224944224484444401111110012222200000000074f99f071f89ab31000000a001f4ff1018877ff10019100000001710009ff000b00b00b0
444449444444444444444444444454440111111001222220000000000991719012fabdc100000000001ff1001ffff110001410000000017100000000000b0000
444444444444494444444444444449440111111001222220000000000049990001111110000000000001100001111000000100000000001000000000000b0000
001100100001010010000000111111110011111111111110000003b07999799999a9997900000000000000003000000009000000040000000000000000000000
01791141001719114100000099999999019999999999f941000003b09999999799999999000000b00000000003bbb0009a900000494000000400000000000000
014999910014199991000000449449441944494449449f9100003b0099a99999799f999f00000b0b000000000b3b3b0009000000040000000000000000000000
141919110001491911000000444444441444444444449f9100003b00999999a9999999990b00b00b000000000bb3bb0000000000000000000000000000000000
121f99f100019f99f9100000444444441444444444449f91000003b09a999994994499a9b0b0b000000ddd000b3b3bb000000000000000000000000000000000
019917191017491711710000414441441441441441449f91000003b04999994444444999b00b000000d667d000bbb3b000000a00000009000000040000000000
172999917101299991100000441444140144144144144941000003b04499444444444449000b00000d67666d0000bbb00000a7a000009a900000424000000000
01191191100019119100000011111111001111111111111000003b004444444444444444000b00000555555d000000b000000a00000009000000040000000000
00181181000018118100000000000000000000000000000011113b110000000000000000000000000000000300a0a00000000000001871000000000000000000
0001001000000100100000000000000028888888000000009993b999000000000000000000000000000bbb3000aaa00000000000018887100111111111111110
000000000000000000000000000000002888888800000000493b494400000000000000000000000000b3b3b00aa9aa0000000000018888100658888888888560
000000000000000000000000000000002222222228888888443b444400000000000000000000000000bb3bb000a9a0000000b000002881000612228888222160
0000000000000000000000000000000000dd550028888888443b44440066550000000000000000000bb3b3b00bb3bb0000bbbbb0000271000611112222111160
000000000000000000000000000000000055dd0022222222413b41440228888000000000000000000b3bbb00b00b00b00bbbbbbb000171000600001111000060
0000000000000000000000000000000000dd550000dd55004413b4140288888000000000000000000bbb0000000b0000bbbbbb4b000171000600000000000060
000000000000000000000000000000000055dd000055dd0011113bb10288888000000000000000000b000000000b0000bb4bb4bb001710000d000000000000d0
11111111111111111111111188887777888877770099aa00000000000000000000111111111111111111110000111111001000001000070000700c0000000c00
1dddddd1ddddddd1ddddddd18888777788887777091dc7a00000000000000000014eeeeeeeeeeeeee8eee710012eeefe00000000007000000c000000c0700000
1d555551d5555551d5555551888877778888777709d17ca0000000000000000014e888ee88e88ee8ee8eee7112eeeeee00000700000000700000000700000007
1d555551d5555551d555555188887777a888777a091dc7a000000000000000001482228e228228828828827112e888ee07000000070707000070000000000700
111111111111111111111111888877779a8877a909d17ca000000000000000001228ff28ff2fe22f22f22fa11282228e00707070c77777700777070007777770
1dddd1dddddd1ddddd1dddd18888777709a87a90091dc7a0000000000000000012fffef2f8fffffffeffffa1142ffe2807777777777c77c7c77777c07777c777
1d5551d555551d55551d555188887777009aa9000091ca000000000000000000012afffffffeffffffaffa101ffafff27c77c7c777777c77777777777c777777
1d5551d555551d55551d555188887777000990000009900000000000000000000011111111111111111111001fffffff77c77c77777777777c777777777777c7
4444444444444444000000000005700007000700566666660000056dd650000000000400099009900b330b300000004200100000100008000080090000000900
222222244222222200000000001007000700070056665666000010066001000000000040940f9049b22b32230000449400000000008000000900000090800000
22222224422222220555555000100d0007000700076507650000170dd0610000000000a9f009900908b288200004090200000800000000800000000800000008
1111111111111111000000500001d0000600060007650765000071d00d170000000004aa9049940f283882820240090008000000080808000080000000000800
000000000000000000000050000570005670567007650765055d00000000d550094049aa94900949288828222822088000808080988888800888080008888880
00000000000000000111110000100700567056700070007010d5000000005d014aa99aa90f0000f0028222202222878808888888888988989888889088889888
00000000000000000000000000100d006670566500700070100d00000000d00109aaaaa049400494002822000220888889889898888889888888888889888888
0000000000000000000000000001d000d66166650070007071d0000000000d17009aa900909f9909000220000000088088988988888888888988888888888898
6767676733333333000000000000000000111100000000000122244000000000000000000000000000000000000000000666d66d666666d6666666d000000000
d6d6d6d6233232330004400000000444018333100000000001122240000000000000000000000000000000000000000066666666666666666d66666600000000
5d5d5d5d2222222300422400dd0022221333338100003000012224400000000000000000000000000000000000000000666ddd66dd6dd66d66d66dd600000000
15151515222225220422224055d2222213333331030333000112224002444420000000000000000000000000000000006dd111d611d11dd1dd1dd11600000000
010101012225222204222240555d222213389331333333300122244000244200007777000000000000000000000000001115551d551551151151151100000000
000000002222222204222240555502221338833133304333011222400002400000000000000000000000000000000000112551512555555d5515555100000000
0000000052222222004224005550000001333310040040400122244000024000000000000000000000000000000000001555d555555515555555d55100000000
00000000222222520004400000000000001442000400004012222244000240000000000000000000000000000000000001111111111111111111111000000000
00cccc0000bbbb000000299001155dd0dddddddd44444444444444440002400000ff0000000800000777400008e8000000000000155555550000000000000000
0c0000c00b0000b0dd024449015555d055d555d52222222222222222000240000ffff000007887007f74f0008e7e800000000000155555550000000000000000
c00cc00cb00bb00b66d2444401155dd05d555d55222222222222222200024000ff2fff0007777f0077f77000e7e7e00000000000155d55550000000000000000
c0c0000cb0b0b00b666d2442015555d0555555551111d1111111111100024000ffff4f007ffff800494940008e7e800000000000155555450000000000000000
c0c0000cb0bbb00b6665022001155dd0551555150005600000000000000240000f4ff000f78887009494900008e8700000000000155555550000000000000000
c00cc00cb0b0b00b55500000015555d05155515500100600000000000002400000ff00008877ff00094900000000070000000000125555550000000000000000
0c0000c00b0000b00000000001155dd01111111100100d00000000000002400000000000ffff0000049400000000007000000000155555550000000000000000
00cccc0000bbbb0000000000015555d0111111110001d0000000000000024000000000000000000000900000000000070000000015555d550000000000000000
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
00101000000000000110001000000010001010000000000001100010000000100000000000000000000000000000000000000000000000000000000000000000
01717100000000001171017110000171017171000000000011710171100001710000000000000000000000000000000000000000000000000000000000000000
17717100000000001771017171000171177171000000000017710171710001710000000000000000000000000000000000000000000000000000000000000000
19919101101010001991119110110191199191011010100019911191101101910000000000000000000000000000000000000000000000000000000000000000
01999119919191001991919191991191019991199191910019919191919911910000000000000000000000000000000000000000000000000000000000000000
00119191919191001999199191919110001191919191910019991991919191100000000000000000000000000000000000000000000000000000000000000000
00014144114410001144141141414141000141441144100011441411414141410000000000000000000000000000000000000000000000000000000000000000
00011011001100000110110010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005555500003000000003000003000000ddd5dd5dddddd5ddddddd5008800000007777000077770000000000000000000000000000000000
000070000000000005dd0005000330000000300000300000ddddddddddddddddd5dddddd020880e0077777700777777000000000000000000000000000000000
000077000000f00000000000000333000003330000333000ddd555dd55d55dd5dd5dd55d02400ee0777777776666677700000000000000000000000000000000
00077770000eef0000055d000033b3300033b300033b3300d551115d115115515515511d020000e0d67777776666667700000000000000000000000000000000
0005777000eeff7000555d60033bbb30033bb33003bbb33011155515551551151151151102244ee0d66777775666667700000000000000000000000000000000
00500050042eef4403355d3303bbbb3003bbbb3003bbbb3011255151255555555515555102244ee00d6666605d66667d00000000000000000000000000000000
02444440f444444f4333333403377330033773300337733015555555555515555555555102211ee000dddd0005ddddd000000000000000000000000000000000
002244000ffffff00444444000333300003333000033330001111111111111111111111002211ee0000000000055550000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009900999099909900909099909990999009909090999099900990000009900990999000000000000000000000000
00000000000000000000000000000000000009090900090909090909009009000909090009090900090909000000090009090999000000000000000000000000
00000000000000000000000000000000000009090990099009090999009009900999090009990990099009990000090009090909000000000000000000000000
00000000000000000000000000000000000009090900090909090009009009000909090009090900090900090000090009090909000000000000000000000000
00000000000000000000000000000000000009090999090909990999009009990909009909090999090909900090009909900909000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000099909900990000009990900090000000999090009990909099909990099009000000000000000000000000
00000000000000000000000000000000000000000090909090909000009090900090000000909090009090909090009090900009000000000000000000000000
00000000000000000000000000000000000000000099909090909000009990900090000000999090009990999099009900999009000000000000000000000000
00000000000000000000000000000000000000000090909090909000009090900090000000900090009090009090009090009000000000000000000000000000
00000000000000000000000000000000000000000090909090999000009090999099900000900099909090999099909090990009000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000044404440444044004440444004404040000040404440400004400440444044400400000000000000000000000000000000000000000000000000
00000000000040004000400040404040404040004040000040404000400040004040444040000400000000000000000000000000000000000000000000000000
00000000000044004400440040404400444040004400000040404400400040004040404044000400000000000000000000000000000000000000000000000000
00000000000040004000400040404040404040004040000044404000400040004040404040000000000000000000000000000000000000000000000000000000
00000000000040004440444044404440404004404040000044404440444004404400404044400400000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777070708888000000000000000000000000000c00ccc00cc0c0c00cc0ccc0ccc00cc00c00c0c0ccc0ccc0ccc0ccc0c0000000000000000000000000
0700000070707070888800000000000000000000000000c0c0c000c0c0c0c0c000c0c00c00c000c0c0c0c00c00c0c0c0c0c000c0000000000000000000000000
0070000070700700888800000000000000000000000000c0c0cc00c0c00c00c000ccc00c00ccc0c0c0c0c00c00cc00cc00cc00c0000000000000000000000000
0700000070707070888800000000000000000000000000c000c000c0c0c0c0c000c0c00c0000c0cc00c0c00c00c0c0c0c0c000c0000000000000000000000000
70000000777070708888000000000000000000000000000cc0c000cc00c0c00cc0c0c00c00cc000cc00cc0ccc0c0c0c0c0ccc0ccc00000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000002323000003030303000000000300000000000000010100010101000707000000000000000303000012930140400000000000101083838300000000000101010300000000010100002323000023000000000000000303030301000000200000000303030000000302010101000000000000130000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100010101000000030303000100000300000100000000000003000003000083830000000000000003030300000000000000000000000000
__map__
0000000000000000000000000000000000000026000000002600003a00002600000000000000000000000000000040414200004300530000000053004300004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000262b000000002600000000000000000000000000000040414200004300530000000053004300004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000002b00000000002600000000002b0000000000000000000000000000004041420000430053000000005300430000400000000000c6e80000e7c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000003a0000000000000026000000000000000000000000000000000000000000404142000043005300000000530043000040000000000000d70000d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4849494a00000000000000004849494a000024250000000026000000000000000000000000000000000000000000404142000044005176767676500044000040c7c800000000d70000d700000000c6c7c74849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000002436250000000000240000000000000000000000000000404142570000000000000000000000005640000000000000d70000d7000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c90000000000000000000000000000000000000000000000000000000000000000004041420057000000000000000000005600400000000000c6e80000e7c80000000000d7000000000000000000000000c900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404142765000000000000000000000517640000000000000d70035d7000000000000d700000000000000000000000000000000000000000000000000000000000000002b0000000000002b00000000002b00
00000000000000000000000000000000242323250000000000000000000000000000000000000000000000c20000404142000000000000000000000000000040c7c7c8000000d70000d7000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404142670000000000000000000000006740000000000000d70000d700000000c6c7c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004041425038384500000000000045380051400000000000c6e80000e7c80000000000d700000000000000000000000000000000000000000000000000000000000000000000002b0000000000002b00000000
4849494a00000000000000004849494a00000000000024363625000000000024404142000000000000000000404141414200003800000000000000003800004000000000000000000000000000000000d74849494a00000000000000004849494a00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000404142000000000000000000404141414200003800000000000000003800004000000000000000000000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d40000000000000000000000000000d400290000540000003c3b000000003c0040414235540000000000543540414141420000370054000000005400370000403500000000000035350000000000003541d40000000000000000000000000000d400000000000000000000000000000000000000000000000000000000000000
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
01030100121341233113331143311533117331193311b3211e32121311263212a3112a315003000e3000030001204132040220400204002040020400204002040020400204002040020400204002040020400204
00100000189751797516975159751497513975139751310617900189001890018900169001590014900169001090015900159000c900179000b900159000a900119000a9000b9000b90000900009000090000903
000600000f61413610166150060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
010c00001445314453144531443314423144231441314413146170040000400004000040000400004000040000400004000040000400004000040000400004000040000400004001240000400004000040000400
0106000013723003042b14100304003042d3040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400000
01100000045301202214032085600000009532000000b532045300050000500085300050009530005000b530045300050000500085300050009530005000b530045301202214032000000b532000000b53200000
01100000205520050021522235420050200502285320050200502005020050200502005020050200502005022053200502235422153220522005021c5421c5120050000500005000050000500005000050000500
011000000c1433f21512313141152461512313141150c1431231300000246000c1433f2150c1433f2150c1430c1433f21512313141152461512313141150c1431231300000141000c1433f2153f4153f2150c143
0110000000100001001b112001021c1121e112001000010223112231122311500100001000010200102001020010200102231120010221112201121e112181021c1121c1121c1021711017115181001711017115
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
010f00000c0430c0430c0000c6150c0000c6000c0430c0430c0000c6150c0000c0000c0000c0430c4000c61512303042000b3000b3000b300007052f705247052f705007052f705007052f705007052f70500705
010e00002f5642a552005022756200502005022555427562005022a5620050222502005022f554005022f56400500005022f51400500005022f514005002450200500005042f5000050000500005000050000000
010e00001201412011120150b0140b0110b0150f0140f0110f0151201412011120101201517014001000b0140b0110b0150b0140000000000000002f100001002f1002f100241002f100001002f1000010000000
010e00001b3001b300003001e30000300003001730017300003001b3001b30000300003002a3002f3002f3002f30000300003002f30000300003002f30000300243002f30000300003002f300003000030000300
010c00000000000000135201352018520185201f5201f5201d5201d5201d5201d5201b5201b5201a5201a5201a5201a5201b5201b520185201852018520185201652016520135201352016520165201852018520
010c00000000000000131201312018120181201b1201b1201a1201a1201a1201a120181201812016120161201612016120181201812013120131201312013120131201312013120131201b1201b1201a1201a120
010c0000185201852018520185201852018520165201652016520165201652016520165201652013520135201352013520135201352013520135200f5200f5200f5200f5200f5200f5200f5200f5200000000000
010c00001852018520185201852018520185201652016520165201652016520165201652016520135201352013520135201352013520135201352013520135201652016520135201352016520165201852018520
010c00000c043000000c043000002461324115246230c0430c0430000000000000000c113243140c043000000c113000000c0430000024615000000c0430c0000000000000246252421224625242002421224200
011000000c743007000070000700246150000000700007000c74317700197001b7003111421700311142a7000c743007000e70000700246150c70000700007000c74300700007000070031114246153111400700
010c00000d0320f02212012140221603214022120120f0220d0320f01212022140121602216015120000f0000d0320f02212012140221603214022120120f0220d0320f01212022140121602216015120000f000
01100000105400c14310523150301502004613180301c012105400c143105231503015020046131803004613285250c1431c5231503015020046131803010012105400c143105231503015020046131803004613
011000000f5400c14314523120301202004613140301c0120f5400c1431052312030120202461514030246150f5400c14310523120301202004613140301c0120f5400c143105231203012020246151403024615
01100000000000d0031b5241b5121b5152252422512225150f5002352423512235152052420512205152252422512225151b5241b5121b5152252422512225150f50023525235240000020525205241400022522
011000000f5200c123155441353015020155201802015522105201553210520105441502013542175320c0331555018615150141501015554135421802015544100200c123105401502013564175621802015544
011000000f5120f5121b5121b5121b51522512225122251222515235122351223512205122051220512225120f5120f5151b5121b5120f5152251222512225150f51223512235122351520512205122051522512
01080020005300054200532005120053200512005320051203550035420353203512035320351203532035120555005542055320551205532055120553205512075500753207522075120a5500a5420c5500c542
010800000053000542005320051200532005120053200512035500354203532035120353203512035320351205550055420553205512055320551205532055120355003532035220351202550025420055000542
010800000556405542055320553205520055220552205512035640354203532035320352003522035220351202564025420253202532025200252202522025120756407542075320751200554005320052200512
010800000c04300742007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c70024615077420773207732000233c7050c01300000
010800000c0330a7220a7200a7120c0430a7122460524000246150874208730087320c0430871224605000000c0430774207730077320c043077122460500000246150374203732027320c0430c0030c0330c003
011000000c04300742007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c70024615077420773207732000233c7050c01300000
011000000c04300742007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c7002461503742037320273218731187321f7411f752
010c00001f7421f715007320073200043007100c023240002461503742037320373200043037100c023000000c04305742057320573200023057100c0233c7002461503742037320273202732050230c01300000
010800000a5300a5420a5320a5120a5320a5120a5320a51208550085420853208512085320851208532085120754007542055400554203540035420254002542075500753207522075120a5500a5420c5500c542
010800000a5600a5620a5520a5320a5520a5320a5420a52208560085520855208522085520852208552085220756007562055500553203550035320254002522075600756207552075320a5500a5320c5400c522
__music__
01 48450507
00 48450607
00 47460807
02 47450506
04 52141516
01 53511113
00 57551011
00 585c1113
00 595c1112
02 5a5c1012
01 5b5b1f5b
00 415e205f
00 41421f60
00 41422062
00 41422263
00 41422061
00 41421f61
02 41422021
01 41422427
00 41422527
00 41422427
00 41422628
00 41422427
00 41422527
02 4142272c
02 41422d44

