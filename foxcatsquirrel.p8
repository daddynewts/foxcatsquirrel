pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- foxcatsquirrel
-- by james newton

-- init + variables

function _init()

 level=0
 count=0
 points=0
 
 init_times()

 enemyangle=0
 enemyapproach=0
 
 -- sfx
 intro_jingle = 6,1
 eat_sfx = 14,1
 death_sfx = 1,1
 jump_sfx = 0,1
 slide_sfx = 2,1
 skull_sfx = 3,1
 bonus_sfx = 13,1
 spring_sfx = 4,1
 ghost_sfx = 12,1
 menu_sfx = 10,1
 balloon_sfx = 13,1
 --shockwave_sfx = 2

 -- music
 music_level1 = 0 
 music_level2 = 4
 music_level3 = 7
 
function rndb(low,high)
 return flr(rnd(high-low+1)+low)
end

 -- crumbs
 effects = {}

 -- effects settings
 explode_size = 1
 explode_amount = flr(12)

 splash={
  sp=92,
  x1=48,--304,
  y1=105,
  x2=304,
  y2=110,

 }
 
 waterfall={
  x1=50,
  y1=80,
  x2=77,
  y2=112,
  lx1=53,
  ly1=81,
  ly2=86,
  ly3=91,
 }

 player={
  sp=1,
  x=8, -- default 56, high 8
  y=24,-- default 104, high 16
  w=8,
  h=8,
  flp=false,
  dx=0, -- means player is not moving at the start
  dy=0,
  max_dx=3,	-- default 3
  max_dy=3, -- default 3
  acc=0.4, -- default 0.5
  boost=4, -- default 4
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

 --enemies={
 ghosts={
  ghost={ ghost_sp=10, x=100 }
 }
 
 skulls={ 
  skull={ skull_sp=13, x=10 }
 }
  
 foods={}
  food={
  x=x,
  y=y,
  h=8,
  w=8,
  xint=32,
  yint=32
 }
 
  food_start=26
  food_count=4
  
 bonuses={}
  bonus_start=14
  bonus_count=1
   
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
 glidetime=0
 leveltime=1
 delay=100
 timededuction=0
end
 
function init_platforms()
 -- v for vertical 
 
 vplatform={
  x=150,--150
  y=60,
  lsprite=36,
  rsprite=37,
 }
 
 -- h for horizontal
 hplatform={
  x=340,
  y=70,
  lsprite=36,
  rsprite=37,
 } 
end
 
function test_mode()
-- edit test parameters here
-- not in the main body!
-- sfx(-1)
-- music(-1) -- music off
 timegain=count -- default 12
 timeleft-=timededuction
 timededuction=0.1*(count/6) -- default 0.1*(count/6)
end

function test_ui()
 --print("count: "..count,cam_x+1,1,7)
 --print("approach: "..enemyapproach,cam_x+1,17,7) 
 --print("vplatform.y: "..vplatform.y,cam_x+1,9,7)
 --print("hplatform.x: "..hplatform.x,cam_x+1,17,7)
 --print("delay: "..delay,cam_x,1,7)
 --print("ghost x: "..ghost.x,cam_x+1,17,7)
 --print("skull.x: "..skull.x,cam_x+1,25,7)
 -- food hitbox
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
 make_bonus()
 make_balloon()
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
end

function update_gameover()
	music(-1)
 delay-=1
	if delay<=50 and	btnp(❎) then
	 _init()
	end
end

function timecheck()
 if timeleft >=78 then
  timeleft=78
 end
 if timeleft <= 2 then
  init_gameover() --time up  
 end
 if timededuction>=10 then
  timededuction=10
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
   
 -- fan = flag 6
 elseif collide_map(player,"down",7) then
   player.dy-=5
    
 -- ice = flag 3
 elseif collide_map(player,"down",3) then
   friction=1
   player.max_dx=4
   
 -- spring = flag 4
 elseif collide_map(player,"down",4) then
   player.dy=-6 -- default 5.2
   player.jumping=true
   sfx(spring_sfx)

 -- spikes = flag 5   
 elseif collide_map(player,"down",5) then
   init_gameover()  
 
 elseif collide_map(player,"up",5) then
   init_gameover()
  
 else
 
 -- default
   friction=0.85
   player.max_dx=3
   player.boost=4
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
 and not btn(➡️) --then
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
   sfx(slide_sfx)
 end
 
  -- slide turn to right
 if player.running
  and player.dx<=0
  and player.landed
  and btn(➡️) then
   player.running=false
   player.sliding=true
   sfx(slide_sfx)
  end
 
 --jump
 if btnp(❎)
 and player.landed 
 and not player.jumping
 and not btn(⬇️)
 then
    player.dy-=player.boost
    player.landed=false
    sfx(jump_sfx)
 end
 
 -- gliding
 if btn(❎)
 and player.falling
 and not player.jumping
 then player.gliding=true
      player.falling=false
      player.jumping=false
      player.dy/=1.3
      glidetime+=0.2
 else if not btn(❎)
  and player.falling
  then player.gliding=false
      glidetime=0
 end 
 
 -- running - unsatisfying
 --if btn(🅾️)
 --and player.landed
 --and player.running
 -- then 
 --  player.dx=(player.dx*1.2)
 --  player.max_dx=5
 -- end
 --end
 
 -- shockwave trial
 --if btn(🅾️) then
 -- make_shockwave()
 -- end
 end

  --fast fall
 if btn(⬇️) 
 and not player.landed
 then player.fastfall=true
      player.dy=10
 end
 
 -- drop-through
 --if player.landed
 if collide_map(player,"down",0)
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
 else --player idle
  
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
 spr(30,96,104+flr(sin(leveltime)))
 draw_platforms() 
 spr(player.sp,player.x,player.y,1,1,player.flp)
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
end

function draw_waterfall()
	rectfill(waterfall.x1,waterfall.y1,waterfall.x2,waterfall.y2,12)
  waterfall.ly1+=2
  waterfall.ly2+=2
  waterfall.ly3+=2
 if waterfall.ly2>=waterfall.y2 then
--   waterfall.ly1=80
   waterfall.ly2=80
 elseif waterfall.ly1>=waterfall.y2 then
   waterfall.ly1=80
 elseif waterfall.ly3>=waterfall.y2 then
   waterfall.ly3=80
--   waterfall.lx1=flr(rnd(18)+waterfall.x1)
  end
-- line(waterfall.lx1,waterfall.ly1,waterfall.lx1,waterfall.ly2,7)
 print("░░░",waterfall.lx1+0.9*sin(leveltime),waterfall.ly1,7)
 print("░░░",waterfall.lx1+0.7*cos(leveltime),waterfall.ly2,1)
 print("░░░",waterfall.lx1+0.6*sin(leveltime),waterfall.ly3,13)
 print("░░░",waterfall.lx1+0.5*cos(leveltime),waterfall.ly1+7,13)
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

 splash.sp+=0.5
   if splash.sp>95 then
      splash.sp=92
    end
end
-->8
-- gimmicks

function level_gimmicks()

 leveltime+=0.01
 
 -- moving platform: ⬆️+⬇️
 vplatform.y+=cos(leveltime)--2*cos(t())
   
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
      x=flr(rnd(80)+16),
      y=flr(rnd(80)+20),
    }
    add(foods,food)
    end
 end
  
 if level>=1 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(90)+16),
    y=flr(rnd(80)+15),
   }
  add(foods,food)
 end
 end
end

function draw_food()
 for food in all(foods) do
  spr(food.sprite,food.x,food.y)
 end
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
--   if #ghost>=1 then
--     orbit=false
--    end
   end
  end
end

function add_foodpoints()
 points+=100+10*flr(glidetime)
 -- points+=flr(10000/timeleft)
 timeleft+=timegain	 --default 25?
 count+=1
 del(foods,food)
 sfx(eat_sfx)
 crumb=pget(food.x+3,food.y+3)
 init_game()
end
 
function make_bonus()

 if count==10 then
  for i=1,1 do    
   bonus={
    sprite=14,
    x=60+(cam_x),
    y=10,
   }
  add(bonuses,bonus)
 end
 end
end

function move_bonus()
 bonus.y-=0.2*cos(leveltime)
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
      sfx(bonus_sfx)
      init_levelover()
  end
 end
end

function draw_bonus()
 for bonus in all(bonuses) do
  spr(bonus.sprite,bonus.x,bonus.y)
 end
end

function make_balloon()

 if count==11 then
--flr(rnd(10)+5) then
  for i=1,1 do    
   balloon={
    sprite=61,
    x=player.x,
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
      sfx(balloon_sfx)
   end
 end
end

function draw_balloon()
 for balloon in all(balloons) do
  spr(balloon_sp,balloon.x,balloon.y)
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
  circfill(99,134,80,11) -- far hill
  circ(99,134,80,7) -- far outline
  circfill(126,154,80,3) -- near hill
  circ(126,154,80,5) -- right outline
  circfill(30,174,110,3) -- near hill
  circ(30,174,110,1) -- left outline
  circfill(80,16,8,10) -- sun
  draw_clouds()
  end
 
 -- jungle
 if level==1 then
  sky.colour=3 -- dark green
   pal(5,2,1)
   pal(6,4,1)
   pal(13,9)
 end
 
 -- castle outside
 if level==2 then
  
  sky.colour=0 -- dark blue
  pal(6,5) -- pale -> dark grey
  pal(9,4) -- orange -> brown
  pal(8,2) -- red -> maroon
  pal(7,13) -- white -> blue-grey
  pal(11,3) -- pale -> dark green
  pal(15,4) -- peach -> brown
  pal(10,2) -- yellow -> maroon
  pal(12,1) -- pale -> dark blue
  pal(14,2) -- pink -> maroon

 end
 
 -- castle inside
 if level==3 then
  pal()
  sky.colour=0
  circ(cam_x+64,64,14,13)
  circfill(cam_x+64,64,13,1)
  rectfill(cam_x+50,64,cam_x+78,127,1)
  rect(cam_x+50,64,cam_x+78,127,13)
  line(cam_x+51,64,cam_x+77,64,1)
 end
 
 -- final level
 if level==4 then
  pal()
 end 
end

function level_music()
 if level==0 then
  music(music_level1)
 elseif level==1 then
  music(music_level2)
 elseif level==2 then
  music(music_level3)
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
 rectfill(0,49,127,51,4)

 -- title in sprites
 sspr(0,64,56,8,13,36,112,16)
 spr(144,83,35) -- acorn
 rectfill(13,52,114,53,1)
    
 -- control bg box
 rectfill(25,55,103,71,1)
 rect(25,55,103,71,9)
 
 -- control rivets
 pset(27,57,10)
 pset(27,69,10)
 pset(101,57,10)
 pset(101,69,10)
 
 print("start",30,61,7)
 -- print("press    to start",29,61,7)
 -- print("c",57,61,12)
 --circ(58,63,5,12)
 
 -- c sprite
 spr(112,54,59)
 
 print("help", 69,61,7)
 spr(113,91,59)
 --print("press    for info",29,74,7)
 --print("a",57,74,11)
 -- circ(58,76,5,11)
 
 -- feedback bg box
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
 --player_update()
 if btnp(❎) then
  sfx(9)
  init_game()
  level_music()
 elseif btnp(🅾️) then
  sfx(9)
  _draw = draw_tutorial
  _update = update_tutorial
 end
end

function update_tutorial()
 
 player_animate()

 if btnp(❎) then
  _init()
  init_game()
  level_music() 
 end
end

function draw_tutorial()
 cls()
 rectfill(0,0,127,127,0)
 -- sunny hills
  sky.colour=12 -- light blue
  circfill(99,134,80,5) -- far hill
  circfill(126,154,80,1) -- near
  circfill(30,174,110,1) -- near
  circfill(80,16,8,6)
 pal(4,2)
 pal(10,4)
 pal(11,3)

 map(0,0,0,0)
  
 spr(player.sp,player.x,player.y)
 
 rectfill(player.x+5,player.y-10,player.x+88,player.y-2,0)
 rect(player.x+5,player.y-10,player.x+88,player.y-2,7) 

 --pset for rounded corners
 pset(player.x+5,player.y-10,1)
 pset(player.x+88,player.y-2,1)
 pset(player.x+5,player.y-2,1)
 pset(player.x+88,player.y-10,1)
 
 --speech bubble to mouth
 line(player.x+8,player.y+2,player.x+9,player.y-2,7)
 line(player.x+8,player.y+2,player.x+12,player.y-2,7)

 --fill for bubble arrow
 line(player.x+9,player.y-2,player.x+11,player.y-2,0)
 pset(player.x+10,player.y-1,0)
 
 print("how to play my game!",player.x+8,player.y-8,7)

 rectfill(19,40,109,92,1)
 rect(19,40,109,92,12)
 
 -- 16,48 works 
 -- shadow
 print("get 10 food:",25,48,1) 
 -- text
 print("get 10 food:",26,48,7)

 spr(26,74,47)
 spr(27,82,47)
 spr(28,90,47)
 spr(29,98,47)

 -- shadow
 print("grab key: ",25,56,1)
 -- text
 print("grab key: ",26,56,7)
 spr(14,64,54)
 
 -- shadow
 print("avoid enemies: ",25,64,0)
 -- text
 print("avoid enemies: ",26,64,7)
 spr(12,82,62)
 spr(10,92,62)

 -- shadow
 print("press    to jump",25,72,0) 
 spr(145,49,70)
 -- text
 print("press    to jump",26,72,7)

 -- shadow
 print("hold    to glide",25,80,0)
 -- text
 print("hold    to glide",26,80,7)
-- print("(c)",50,72,12)
  spr(145,45,79)
-- print("(c)",46,80,12)

-- feedback bg box
 rectfill(19,100,109,122,1)
 rect(19,100,109,122,12)
 
 print("ready?",53,104,9)
 print("press    to play!",30,113,7)
 spr(145,54,111)
end

function update_menu()

 delay-=1
 if delay<90 and btnp(❎) then
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
  timeleft=127--timeleft+(timegain*2)
  player.x=(level*128)+8
  player.y=16
  player.dx=0
  player.dy=0
  _update = update_menu
  _draw = draw_levelover
  if level==5 then
   _update = update_gameover
   _draw = draw_youwin
  end
end

function draw_levelover()
 pal()

 -- full-width stripe
 rect(cam_x,33,cam_x+128,63,7)
 rect(cam_x,32,cam_x+128,64,7)
 rectfill(cam_x,34,cam_x+127,62,sky.colour)
 
 -- double-size "level over"
  sspr(68,64,60,8,cam_x+2,36,120,16)

 --rectfill(cam_x+33,53,cam_x+93,59,0)
-- print("your score:".. points,33,54,0)
 print("your score:".. points,cam_x+34,54,7)
 
 rectfill(cam_x+23,108,cam_x+98,121,1)
 rect(cam_x+23,108,cam_x+98,121,12)
 
 print("press   to restart",cam_x+26,112,7)
 spr(145,cam_x+48,111)
end

function draw_gameover()
 pal()
 rect(cam_x,33,cam_x+128,63,7)
 rect(cam_x,32,cam_x+128,64,7)
 rectfill(cam_x,34,cam_x+127,62,1)
 sspr(0,80,60,8,cam_x+25,36,120,16)
 
 -- score bg
-- rectfill(cam_x+33,53,cam_x+93,59,0)
 print("your score: ".. points,cam_x+32,56,7)
 
 rectfill(cam_x+23,108,cam_x+98,121,1)
 rect(cam_x+23,108,cam_x+98,121,12)
 
 print("press   to restart",cam_x+26,112,7)
 spr(145,cam_x+48,111)
end

function draw_youwin()
 pal()
 
 -- full-width stripe
 
 rect(cam_x,33,cam_x+128,63,7)
 rect(cam_x,32,cam_x+128,64,7)
 rectfill(cam_x,34,cam_x+127,62,4)
 
 -- double-size "you win"
  sspr(0,88,60,8,cam_x+32,36,120,16)

 print("you win the game!",cam_x+32,56,7)
 print("score: "..points,cam_x+44,68,7)
 
 -- "press to restart" box
 rectfill(cam_x+20,108,cam_x+100,121,1)
 rect(cam_x+20,108,cam_x+100,121,12)
 print("press ❎ to restart",cam_x+23,112,7)

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
    x=cam_x-player.x,
    y=flr(64)-player.y,
   }
  add(skulls,skull)
  sfx(skull_sfx)
 end
end

function make_ghost()
 
 for i=1,1 do
  ghost={
   x=cam_x-player.x,
   y=flr(64)-player.y,
   }
  add(ghosts,ghost)
  sfx(ghost_sfx)
  ghost.orbit=false
 end
end

function move_skull() 

 for skull in all(skulls) do
-- easy
  skull.x-=((skull.x/100)-(player.x/100))*(player.dx/count+1)
  skull.y-=((skull.y/100)-(player.y/100))*(player.dy/count+1)
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
  
  -- circular movement
  for ghost in all (ghosts) do
   if ghost.x > food.x-20
   and ghost.x < food.x+24
   and ghost.y > food.y-20
   and ghost.y < food.y+24
    then ghost.orbit=true
    else ghost.orbit=false
   end
  end
  
  -- circular movement!
  for ghost in all (ghosts) do
   if ghost.orbit==false then
    ghost.x-=(ghost.x/100)-(food.x/100)
    ghost.y-=(ghost.y/100)-(food.y/100)
   elseif ghost.orbit==true then
--    ghost.x=food.x-(10*cos(enemyangle))
--    ghost.y=food.y-(10*sin(enemyangle))
    ghost.x=food.x-(15*cos(leveltime))
    ghost.y=food.y-(15*sin(leveltime))
   end
  end
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
end

function draw_skull()

 for skull in all(skulls) do
  spr(skull_sp,skull.x,skull.y)
  
  if player.x>=skull.x then
   skull_sp=13
  else skull_sp=12
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
-- crumbs

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
  pset(fx.x,fx.y,fx.c)
 end
end

function update_fx()
	 for fx in all(effects) do
  --lifetime
  fx.t+=2
  if fx.t>fx.die then del(effects,fx) end

   --physics
    if fx.grav then fx.dy+=.25 end
    if fx.grow then fx.r+=.1 end
    if fx.shrink then fx.r-=.1 end

   fx.c=crumb

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
    20, --30+rnd(25),-- die
    rnd(2)-1,  -- dx
    rnd(2)-1,  -- dy
    true,     -- gravity
    false,     -- grow
    false,      -- shrink
    r,         -- radius
    c_table    -- color_table
        )
    end
end
__gfx__
00000000079004007090040007900400709004000790040070900400009004007090040000000000000000000000000006677770066777700000000000000000
0000000004999900409999000499990004999900409999004099990000999900409999007090040000077700000777006777777767777777000000f000000000
0070070040919100049191004091910004919100049191004091910000919100209191004099990000757500007575006117117767117117000009aa00000000
0007700020f99f0009f99f9020f99f0020f99f0020f99f0020f99f0070f99f0772f99f074091910000777700077777706117117767117117000090a000000000
00077000099171907491710709917190799171900991719009917197099171900991719002f99f00077d6d70707d6d0767777777677777770f09000000665500
00700700729999070299990072999907029999077299990772999900029999000099990079917190707777070077770067122777677221774af0000002288880
00000000009009000090090000900800008008000080090000800800409009000090090000999907007007000070070006782770067287704a90000002888880
00000000008008000080080000800000000000000000080000000000780080000008008000080080007007000070070000677700006777000400000002888880
bbbbbbbb44444444bbbbbbbb4444444404111111111111400000000000000000000000000000000000ff0000000800000777400008e8000000a0a00000000000
23b239bb44444444bc32233b444444450411111111111140000000000000000000000000000000f00ffff000007887007f74f0008e7e800000aaa00000000000
2222225b4444494433222233444444440411111111111140000000000000000000000000000009aaff2fff0007777f0077f77000e7e7e0000aa9aa0000000000
422422224544444422244222494444440411111111111140000000000000000000000000000090a0ffff4f007ffff800494940008e7e800000a9a00000030000
4444442249444449224944224894444404111111111111400000000000000000000000000f0900000f4ff000f78887009494900008e8700000aaa0000bb3bb00
4444494444444444444444444484444404111111111111400000000000000000000000004af0000000ff00008877ff00094900000000070000000000b00b00b0
4444444444444444444444444444544404111111111111400000000000000000000000004a90000000000000ffff0000049400000000007000000000000b0000
4944444444444944445444a4444449440411111111111140000000000000000000000000040000000000000000000000009000000000000700000000000b0000
7777777777777777011666777d6667700299999999999990000003b07999799999a9997900000000000000000000000000000000000000000000000000000000
667666766676667601d6666766666c702944449449444ff9000003b09999999799999999000000b0000000000000000000000000000000000000000000000000
6766676667666766011666d66666677024444a44944496690000bb0099a99999799f999f00000b0b000000000000000000000000000000000000000000000000
666d66d6666d66d601d6666666d66c7024444444444496f90000bb00999999a9999999990b00b00b000000000000000000000000000000000000000000000000
66d66d6666d66d66011667dd6d6667702444444444449ff9000003b09a999994994499a9b0b0b000000ddd000000000000000000000000000000000000000000
555555555555555501d66dd555d66c702444424444249ff9000003b04999994444444999b00b000000d667d00000000000000000000000000000000000000000
0000000005111150011667d0011667702524442444429ff900000bb04499444444444449000b00000d67666d0000000000000000000000000000000000000000
00000000055555d001d66c7001d66c70022222222222299000003b004444444444444444000b00000555555d0000000000000000000000000000000000000000
0116677001555dd07777777777777777012224400000000099993b9999999999c7cccc7c122222240000000300a0a00000000000000870000000000000000000
01d66c70011555d0667666766676667601122240033333304493b49444944494cccccccc01122240000bbb3000aaa00000000000008887000000000000000000
0116677001555dd06766676667666766012224403bbaabb34a3b4a4444444444ccc7ccc70122244000b3b3b00aa9aa000000b000002888006588888888888856
01d66c70011555d0666666666666666601122240fbabbabf443b444444444444cccccccc0112224000bb3bb000a9a000b00bb0b0000280006022288888822206
0116677001555dd066566656666666660122244063333336443b44444444444414444144012224400bb3b3b00bb3bb000bbbbbb0000700006000022222200006
01d66c70011555d065666566666666560112224060000006443b44444424442444494444011222400b3bbb00b00b00b00bbb8bbb000070006000000000000006
0116677001555dd0555555556566666601222440600000064443b4444442444244444424012224400bbb0000000b0000bb8bbb4b000070006000000000000006
01d66c70011555d01111111166666666011222406000000622223bb22222222294444444011222400b000000000b0000bbbbbbbb000700006000000000000006
11111111111111111111111111111111888877770bbb3bb3bbbbbb3bbbbbbb3000000000000000000000000000000000001000001000070000700c0000000c00
1666666166666666166666661666666188887777bbbbbbbbbbbbbbbbb3bbbbbb0000000000000000000000000000000000000000007000000c000000c0700000
16d555516d55555516d5555516d5555188887777bbb333bb33b33bb3bb3bb33b0000000000000000000000000000000000000700000000700000000700000007
1655555165555555165555551655555188887777b331113b113113313313311b0000000000000000000000000000000007000000070707000070000000000700
11111111111111111111111111111111888877771112221322122112112112210000000000000000000000000000000000707070c77777700777070007777770
16666166666616666661666666616661888877771142222142222222222222210000000000000000000000000000000007777777777c77c7c77777c07777c777
16d5516d555516d555516d5555516d5188887777011122222222222222222210000000000000000000000000000000007c77c7c777777c77777777777c777777
16555165555516555551655555516551800870070011111111111111111111000000000000000000000000000000000077c77c77777777777c777777777777c7
4444444444444444000000000005600007000700566666660000056d0000000000000400099009900b330b300000004200100000100008000080090000000900
222222244222222200000000001006000700070056665666000010060000000000000040940f9049b22b32230000449400000000008000000900000090800000
22222224422222220555555000100d0007000700076507650000170d00000000000000a9f009900908b288200004090200000800000000800000000800000008
1111111111111111000000500001d0005670567007650765000071d000000000000004aa9049940f283882820240090008000000080808000080000000000800
000000000000000000000050000560005670567007650765055d000000000000094049aa94900949288828222822088000808080988888800888080008888880
00000000000000000111110000100600567056700070007010d50000000000004aa99aa90f0000f0028222202222878808888888888988989888889088889888
00000000000000000000000000100d006665666500700070100d00000000000009aaaaa049400494002822000220888889889898888889888888888889888888
0000000000000000000000000001d000666666650070007061d0000000000000009aa900909f9909000220000000088088988988888888888988888888888898
6767676733333333000560000008800000bbbb00000000000122244000000000000000000000000000000000000000000666d66d666666d6666666d000000000
d6d6d6d62332323300056000008888000b8bbbb00000000001122240000000000000000000000000000000000000000066666666666666666d66666600000000
5d5d5d5d222222230005600008888880bbbbbb8b00003000012224400000000000000000000000000000000000000000666ddd66dd6dd66d66d66dd600000000
15151515222225220005600087777778bbbbbbbb030333000112224002444420000000000000000000000000000000006dd111d611d11dd1dd1dd11600000000
01010101222522220005600087777778bbb89bbb333333300122244000244200000000000000000000000000000000001115551d551551151151151100000000
00000000222222220005600008888880bbb88bbb33304333011222400002400000000000000000000000000000000000112551512555555d5515555100000000
000000005222222200056000008888000bbbbbb0040040400122244000024000000000000000000000000000000000001555d555555515555555d55100000000
00000000222222520005600000088000001442000400004012222244000240000000000000000000000000000000000001111111111111111111111000000000
00cccc0000bbbb002222222201155dd0dddddddd00000000000000000002400000ff0000000800000777400008e8000000000000000000000000000000000000
0c0000c00b0000b022222122015555d055d555d50000000000000000000240000ffff000007887007f74f0008e7e800000000000000000000000000000000000
c00cc00cb00bb00b2222222201155dd05d555d55000000000000000000024000ff2fff0007777f0077f77000e7e7e00000000000000000000000000000000000
c0c0000cb0b0b00b25222222015555d055555555000000000000000000024000ffff4f007ffff800494940008e7e800000000000000000000000000000000000
c0c0000cb0bbb00b2222222201155dd0551555150000000000000000000240000f4ff000f78887009494900008e8700000000000000000000000000000000000
c00cc00cb0b0b00b22122522015555d05155515500000000000000000002400000ff00008877ff00094900000000070000000000000000000000000000000000
0c0000c00b0000b02222222201155dd01111111100000000000000000002400000000000ffff0000049400000000007000000000000000000000000000000000
00cccc0000bbbb0022222222015555d0111111110000000000000000000240000000000000000000009000000000000700000000000000000000000000000000
01111100000000000000011100000000000000000000000011100000000000000000000002200000000000000200002220000000000000002000002000002000
1197711000000000000001710111100000000000000000001710000000000000000000002aa20000000000002a2002aaa200000000000002a20002a20002a200
19997710000000000000017111771000000007000000000017100000000000000000000029920222020202222920299992022022020022229222299a22229200
1991111111110111111116771a11111111111111111111111a100000000000000000000029922aaa2a2a2aaa29202992202aa2aa2a22aaa292aaa292aaa29200
1999119a191a1177117711611aaa11aa1a1a1a1aa1aa1aaa1a100000000000000000000029922929292929292920299222929292929292929292929292922000
14911419119116111617116111191919191919191191191919100000000000000000000029992992299229922920029992992292929299209299229299229200
14411441141916661667716114411444144114141141144114100000000000000000000002220220022002200200002220220020202292002022002022002000
11111111111111111111111111111114111111111111111111100000000000000000000000000000000000000000000000000000000020000000000000000000
0000000000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000011000c0000c00b0000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00014910c00cc00cb00bb00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00144491c0c0000cb0b0b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013bbb1c0c0000cb0bbb00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013bbb1c00cc00cb0b0b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000133100c0000c00b0000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000cccc0000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222000000000000000000022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02777200000000000000000277720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2aaaa200000000000000002aa2a20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29922002200220200222002992922020222022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29929229922992922999202992929292999299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24424242422424242424202442424242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02444244242424242442000244224422442242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222022220222220222000222202200222020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000000000000110001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01717100000000001171017110000171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17717100000000001771017171000171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19919101101010001991119110110191000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01999119919191001991919191991191000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00119191919191001999199191919110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00014144114410001144141141414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011011001100000110110010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccc777ccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccc77777cccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccc77777cccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccc77777777ccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccc7777777777ccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccaaaaacccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccaaaaaaaaacccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccaaaaaaaaaaaccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccaaaaaaaaaaaaacccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccfccccccaaaaaaaaaaaaaaaccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccc9aacccccaaaaaaaaaaaaaaaccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccc9caccc8e8aaaaaaaaaaaaaaaacccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccfc9ccccc8e7e8aaaaaaaaaaaaaaacccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccc4afcccccce7e7eaaaaaaaaaaaaaaacccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccc4a9cccccc8e7e8aaaaaaaaaaaaaaacccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccc4cccccccc8e87aaaaaaaaaaaaaaacccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccca7aaaaaaaaaaaaaccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccaa7aaaaaaaaaaaaccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccaa7aaaaaaaaaacccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccaaaaaaaaaaaccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccaaaaaaaaacccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccaaaaacccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccc
cbbb3bb3bbbbbb3cccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccbbb3bb3bbbbbb3c
bbbbbbbbb3bbbbbbccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccbbbbbbbbb3bbbbbb
bbb333bbbb3bb33bccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccbbb333bbbb3bb33b
b331113b3313311bccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccb331113b3313311b
1112221311211221ccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccc1112221311211221
1142222122222221ccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccc1142222122222221
c11122222222221cccccccccccccccccccccccccccccccccc777777777777777777777777777777777777777777777ccccccccccccccccccc11122222222221c
cc111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc7c9cc4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc4c9999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc2c9191cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc72f99fc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc991719ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc9cc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8cc8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3ccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3c333cccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333ccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333c4333cccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777747747477777cccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777bbbbbb4bbbb4bbbbb7777777ccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777ccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777bbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbb777cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777bbbbbbbbbbbbbbbbbbbbbbbb3b333bbb3b333bbbbbbbbbbbbbbbb77
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbb3333333b3333333bbbbbbbbbbbbbbbbb
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbbbb333b4333333b4333bbbbbbbbbbbbbbbb
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4bb4b4bb4bb4b4bbbbbbbbbbbbbbbbb
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4bbbb4bb4bbbb4bbbbbbbbbbbbbbbbb
cccccccccccccccccccc111111111111111111111ccccccccccccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cccccccccccc1111111133333333333333333333311111111ccccccccc77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccccccc11111333333333333333333333333333333333333311111cc6588888888888856bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ccc1111333333333333333333333333333333333333333333333331161222888888222b6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1113333333333333333333333333333333333333333333333333333363111222222bbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333333333333333333333633333111bbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
33333333333333333333333333333333333333333333333333333333633333333111bbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333333333333363333333333311b6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333333666d66d666666d6666666d6666666dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333336666666666666666666666666d666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
333333333333333333333333333333333333333333333333666ddd66dd6dd66ddd6dd66d66d66dd6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5555555555
3333333333333333333333333333333333333333333333336dd111d611d11dd111d11dd1dd1dd116bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55555553333333333
3333333333333333333333333333333333333333333333331115551d5515511555155115115115111bbbbbbbbbbbbbbbbbbbbbbbbbb555533333333333333333
333333333333333333333333333333333333333333333333112551512555555d2555555d55155551311bbbbbbbbbbbbbbbbbbbb5555333333333333333333333
3333333333333333333333333333333333333333333333331555d55555551555555515555555d55133311bbbbbbbbbbbbbbb5553333333333333333333333333
333333333333333333333333333333333333333333333333311111111111111111111111111111133333311bbbbbbbbbb5553333333333333333333333333333
333333333333333333333333333333333333333333333333333333cc1ccc1ccc1ccc1cccc333333333333331bbbbbbb553333333333333333333333333333333
333333333333333333333333333333333333333333333333333333cccc1ccc1ccc1ccc1cc33333333333333311bbb55333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333cc1ccc1ccc1ccc1cccc3333333333333333311533333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333cccc1ccc1ccc1ccc1cc3333333333333333333133333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333ccdcccdcccdcccdcccc3333333333333333333313333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333ccccdcccdcccdcccdcc3333333333333333333331133333333333333333333333333333333
333333333333333333333333333333333333333333333333333333ccdcccdcccdcccdcccc3333333333333333333333313333333333333333333333333333333
333333333333333333333333333333333333333333333333333333ccccdcccdcccdcccdcc3333333333333333333333331333333333333333333333333333333
3bbb3bb3bbbbbb3bbbbbbb33333333333333333333333333333333ccdcccdcccdcccdcccc33333333333333333333333331133333bbb3bb3bbbbbb3bbbbbbb33
bbbbbbbbbbbbbbbbb3bbbbbb333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333331333bbbbbbbbbbbbbbbbb3bbbbbb
bbb333bb33b33bb3bb3bb33b333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333133bbb333bb33b33bb3bb3bb33b
b331113b113113313313311b333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333313b331113b113113313313311b
111222132212211211211221333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333331111222132212211211211221
114222214222222222222221333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333114222214222222222222221
311122222222222222222213333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333311122222222222222222213
331111111111111111111133333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333331111111111111111111133
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333313333333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333331333333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333133333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333133333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333313333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333331333333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333333133333333333333
333333333333333333333333333333333333333333333333333333ccccccccccccccccccc3333333333333333333333333333333333333333313333333333333
3333333333333333333333333333333333bbbb3333333333333333ccccccccccccccccccc3333333333333333333333333a3a333333333333331333333333333
333333333333333333333333333333333b8bbbb333333333333333ccccccccccccccccccc3333333333333333333333333aaa333333333333333133333333333
333333333333b3333333333333333333bbbbbb8b33333333333c37cc7ccc77cc7ccc77ccc333333333333333333333333aa9aa33333333333333b33333333333
33333333b33bb3b33333333333333333bbbbbbbb33333333333333ccdc7cdc7cdc7cdc7cc3733333333333333333333333a9a33333333333b33bb1b333333333
333333333bbbbbb33333333333333333bbb89bbb33333333333333cc7cdc7cdc7cdc7cdc7333333333333333333333333baaab33333333333bbbbbb333333333
333333333bbb8bbb3333333333333333bbb88bbb3333333333337777777c7777777c7777773333333333333333333333b33b33b3333333333bbb8bbb33333333
33333333bb8bbb4b33333333333333333bbbbbb3333333333337777c7777777c7777777c777333333333333333333333333b333333333333bb8bbb4b33333333
33333333bbbbbbbb333333333333333333144233333333333337c7777777c7777777c777777333333333333333333333333b333333333333bbbbbbbb13333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777c7777777c7777777c7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
23b239bbbc32233b23b239bbbc32233b23b239bb23b239bb23b239bbbc32233b23b239bb23b239bbbc32233b23b239bb23b239bbbc32233b23b239bb23b239bb
2222225b332222332222225b332222332222225b2222225b2222225b332222332222225b2222225b332222332222225b2222225b332222332222225b2222225b
42242222222442224224222222244222422422224224222242242222222442224224222242242222222442224224222242242222222442224224222242242222
44444422224944224444442222494422444444224444442244444422224944224444442244444422224944224444442244444422224944224444442244444422
44444944444444444444494444444444444449444444494444444944444444444444494444444944444444444444494444444944444444444444494444444944
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
70000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000007
07000000000003777333333333333333333333333333333333333333333000000000000000000007007700770077077707770000000007770777077700000007
00700000000003733333333333333333333333333333333333333333333000000000000000000007070007000707070707000070000000070707070700000007
07000000000003773333333333333333333333333333333333333333333000000000000000000007077707000707077007700000000000770707070700000007
70000000000003733333333333333333333333333333333333333333333000000000000000000007000707000707070707000070000000070707070700000007
00000000000003777333333333333333333333333333333333333333333000000000000000000007077000770770070707770000000007770777077700000007
70000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000007
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__gff__
00000000000000000000000023230381030303030303000000030000000000000101000001010007070000000023030302000101001101010b0000000000111103030303030101010000000000000000010100002323008023000000000000000303000001000000000000000303030000000302010100000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000026000000000000000000002600000000000000000000000000000040414300530000530000000053000053004100000000000000000000000000000000410000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000003a2600000000000000000000000000000040414300535200530000000053005253004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040414300530000530000000053000053004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005640414300530000530052000053000053004132320000000000323200000000003232410000000000000000000000000020230000000000000000000000000000000000000000000000000000000000000000
4547000000000000000000000000454700000000000000000000000000000000000000000000000000000000560040414351500000530000000053000051504100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000024362500003a00000024000000000000000000000056000040414300000000530000000053000000004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006500000000000000000000000000000000000000000000000000000000000051515140414300520000530000000053000000004100000032320000000000000032320000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000065650000000000000000000000000000000000000000000000000000000000000000404143000000005300000000530000000041000000000000000000000000000000004100000000000000000000000000004100000000000000000000000000000000002b0000000000002b00000000002b00
000000000000003e3f000000000000000000000000000000000029000000002400000000000000000000000000004041430000000053003e3f0053000000004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000006c6d6d6e00000000000024250000000000000000242500000000000000000000000000000000000040414300000000505050505050000000004100000000003500000000350000000000410000000050000000005000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000002600000000000000000000000000000035000000000000000000000000404143000000000000000000000000520041000000000021200000202100000000004100000000212020202021000000004100000000000000000000000000000000000000002b0000000000002b00000000
4546470000000000000000000045464700000000000024363625000000000024747400000000000000000000000040414300000052000000000000000000004100000000003100000000310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000260000000000000000310000000063000000630000000040414300000000670052000067000000004100000000003100000000310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
003c000064000000002a00001f003c000029003b000000003c00003b00543c003100002900620000006200540000404143000f005477000000007754000f0041000000000031003e3f00310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
1012101210101012101012101012101010121012121010121012121210121012606060606060000000606060606060604141424242424242424242424242423333333333333333333333333333333333410000500031000000003100500000416161616161616161616161616161616127272727272727272727272727272727
1113111111131113111111111311111313131313131313131313131313131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
__sfx__
010301000c4111d41120411254112941130411344113c411364143f2042d2042c2042c2042c204282042820401204132040220400204002040020400204002040020400204002040020400204002040020400204
00100000189751797516975159751497513975139751310617900189001890018900169001590014900169001090015900159000c900179000b900159000a900119000a9000b9000b90000900009000090000903
010600000f61413610166150060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
010c00001445314453144531443314423144231441314413146170040000400004000040000400004000040000400004000040000400004000040000400004000040000400004001240000400004000040000400
0106000013723003042b14100304003042d3040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400000
01100000045301202214012085300000009532000000b532045300050000500085300050009530005000b530045300050000500085300050009530005000b530045301202214012000000b530000000b53000000
01100000205520000021522235420000200002285320000200002000020000200002000020000200002000022053200002235422153220522000021c5421c5120000000000000000000000000000000000000000
011000000c1433f21512313141152461512313141150c1431231300000246000c1433f2150c1433f2150c1430c1433f21512313141152461512313141150c1431231300000141000c1433f2153f4153f2150c143
01100000204420000221442234420000200002284520040200402004020040200402004020040200402004022045200402234522145220432004021c4521c412044020000200002000020b002000020b00200002
000800002b551395543c5552850000500005000050000500005003050000500005000050000500005000050000500005000050033500005000050000500005000050000500005000050000500005000050000500
000600001c522205422f5520e502085021b0021a0021900219002170021600215002150021260212602116021160210602106020f602110020f6021060210602116021260212602136021360213602116020e602
01100000106132a100001002710000100001002510027100001002a1000010022100001002f100001002f100000002f500000002f500245002f500005002f500000002f500000002f500005042f500005002f500
010800002666500005186051a65518605186050e63518605000050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500005
0106000028542285522c5522c5522f5522f5523455234542345323451200500005000050000500005000050000500005000050000500005000050000502000000000000000000000000000000000000000000000
000a00001413112141161513416100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001000010000100
010800000567305631056110000100001000010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100000
011000200c0233f2150000000000186150000000000123130c023000000000000000186150000018615000000c0233f2150000000000186150000000000123130c02300000000000000018615000001861500000
011000202e7223072033722357223372030722307212e7202e7202e7222b7202b7202e7212e7202e720307223372033720307222e7202e7202e7212e7202e7202c7222e720307203072237720377203772137721
01100020163121b332243231d3120c312133320f3230c3121131224332223231f31218312113320c3230a312133121d322183330f3420f3120a332073230c3121d3121d322163330f3420f3120f3220f3331b342
011000001372216720187221b722187201672213721000001372216720187221b722187201672213721000001372216720187221b722187201672213721000001672016720147221672018720187221f7201f720
010e00000c0430c043000001861500000246000c0430c0430c000186150000000000000000c0430c400186152a303042003b3003b3003b300007052f705247052f705007052f705007052f705007052f70500705
010e00002f5642a552005022756200502005022555427562005022a5620050222502005022f554005022f56400500005022f51400500005022f514005002450200500005042f5000050000500005000050000000
010e00001211412111121150b1140b1110b1150f1140f1110f1151211412111121101211523114001000b1140b1110b1150b11517100241002f100001002f1002f100241002f100001002f100001000010000100
010e00001b3111b314003021e31200302003021731417315003001b3141b30000300003002a3242f3002f3242f30000300003002f30000300003002f30000300243002f30000300003002f300003000030000300
010c0000135201352018520185201f5201f5201d5201d5201d5201d5201b5201b5201a5201a5201a5201a5201b5201b5201852018520185201852016520165201352013520165201652018520185201852018520
010c0000131201312018120181201b1201b1201a1201a1201a1201a120181201812016120161201612016120181201812013120131201312013120131201312013120131201b1201b1201a1201a1201812018120
010c000018520185201852018520165201652016520165201652016520165201652013520135201352013520135201352013520135200f5200f5200f5200f5200f5200f5200f5200f52000000000001852018520
010c00001852018520185201852016520165201652016520165201652016520165201352013520135201352013520135201352013520135201352016520165201352013520165201652018520185201850018500
010c00000c0430000000000000002461500000246150000000000000000c043000000c0430000000000000000c0430000024615000000c0430c00000000000002461500000246150c00024615000000000000000
__music__
01 48050750
00 48050807
00 47060750
02 07050650
01 52111044
02 13111044
04 57151416
01 181c4344
00 191c1844
00 1a1c5544
02 1b424344

