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
 addfood=1
 
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
  x=5,
  y=5,
  h=8,
  w=8,
 }
 
  food_start=26
  food_count=4
  
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
 glidetime=0
 leveltime=1
 delay=100
 timededuction=0
 platformtime=0
end
 
function init_platforms()
 -- v for vertical 
 
 vplatform={
  x=52,--150
  y=60,
  lsprite=69,
  rsprite=71,
 }
 
 -- h for horizontal
 hplatform={
  x=340,
  y=70,
  lsprite=36,
  rsprite=37,
 } 
 
 fallplatform={
  x=170,
  y=36,
  sp=118,
  dropheight=50,
  wobbletime=30,
  falltime=50,
  respawn=0
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
   gravity=0.3
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
    player.sp=23
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
 
 if level==1 then
  vplatform.x=150
 else vplatform.x=52
 end
 
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
  
 --falling platforms
  
 if  fallplatform.y > player.y -- -4
  and fallplatform.y < player.y+10 -- +4
  and fallplatform.x > player.x-8 -- 4
  and fallplatform.x < player.x+8
   and player.dy>0
   then player.fallplatform=true
  else player.fallplatform=false
       end
 
 if player.fallplatform then
  platformtime+=1
  player.y=fallplatform.y-8
  player.dy=0
  player.landed=true
  player.falling=false
  player.gliding=false
 end

 if platformtime>=fallplatform.wobbletime
  then fallplatform.y+=cos(platformtime/4)
 end
 
 if platformtime>=fallplatform.falltime then
  fallplatform.y+=flr(platformtime/20)
 end
 
 if fallplatform.y>=fallplatform.dropheight then
   fallplatform.y+=5*flr(leveltime)
    fallplatform.respawn+=1
 end
 
 if fallplatform.respawn>=50 then
  init_platforms()
  platformtime=0
 end
end

function draw_platforms()
 spr(vplatform.lsprite, vplatform.x,vplatform.y)
 spr(vplatform.rsprite, vplatform.x+8,vplatform.y)
 
 spr(hplatform.lsprite,hplatform.x,hplatform.y)
 spr(hplatform.rsprite,hplatform.x+8,hplatform.y)

 spr(fallplatform.sp,fallplatform.x,fallplatform.y)
end
-->8
-- grabbables

function level_food()
 
  if level==0 then
    for i=1,1 do    
     food={
      sprite=flr(rnd(food_count)+food_start),
      x=flr(rnd(80)+12),
      y=flr(rnd(60)+20),
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
 timeleft+=timegain	--default 25?
 count+=addfood
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

 if count==flr(rnd(10))+10 then
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
  -- dancing flower
  spr(30,88,104+flr(sin(leveltime)))
  end
 
 -- jungle
 if level==1 then
  sky.colour=0 --3 -- dark green
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
  --player.y=16
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
   if ghost.orbit==false then
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
bbbbbbbb44444444bbbbbbbb4444444401111110012222200000000000900400000000000000000000ff0000000800000777400008e8000000a0a00000000000
23b239bb44444444bc32233b444444450111111001222220000000000099990000000000000000f00ffff000007887007f74f0008e7e800000aaa00000000000
2222225b4444494433222233444444440111111001222220000000000091910000000000000009aaff2fff0007777f0077f77000e7e7e0000aa9aa0000000000
4224222245444444222442224944444401111110012222200000000070f99f0700000000000090a0ffff4f007ffff800494940008e7e800000a9a00000030000
4444442249444449224944224894444401111110012222200000000009917190000000000f0900000f4ff000f78887009494900008e8700000aaa0000bb3bb00
4444494444444444444444444484444401111110012222200000000002999900000000004af0000000ff00008877ff00094900000000070000000000b00b00b0
4444444444444444444444444444544401111110012222200000000040800800000000004a90000000000000ffff0000049400000000007000000000000b0000
4944444444444944445444a4444449440111111001222220000000007000000000000000040000000000000000000000009000000000000700000000000b0000
000000000000000000000000999999990299999999999990000003b07999799999a9997900000000000000000000000000000000000000000000000000000000
888888880000000000000000449444942944449449444ff9000003b09999999799999999000000b0000000000000000000000000000000000000000000000000
9999999900000000000000004444444424444a449444966900003b0099a99999799f999f00000b0b000000000000000000000000000000000000000000000000
aaaaaaaa00000000000000004444444424444444444496f900003b00999999a9999999990b00b00b000000000000000000000000000000000000000000070000
bbbbbbbb0000000000000000444444442444444444449ff9000003b09a999994994499a9b0b0b000000ddd000000000000000000000000000000000000000000
ccccccc00000000000000000442444242444424444249ff9000003b04999994444444999b00b000000d667d00000000000000000000000000000000000000000
111111000000000000000000444244422524442444429ff9000003b04499444444444449000b00000d67666d0000000000000000000000000000000000000000
00000000000000000000000022222222022222222222299000003b104444444444444444000b00000555555d0000000000000000000000000000000000000000
00000888888000000000012224400000012224400000000099993b9999999999c7cccc7c122222240000000300a0a00000000000000870000000000000000000
0000899999980000000001122240000001122240033333304493b49444944494cccccccc01122240000bbb3000aaa00000000000008887000000000000000000
00089aaaaaa980000000012224400000012224403bbaabb34a3b4a4444444444ccc7ccc70122244000b3b3b00aa9aa000000b000002888006588888888888856
0089abbbbbba9800000001122240000001122240fbabbabf443b444444444444cccccccc0112224000bb3bb000a9a000b00bb0b0000280006022288888822206
089abccccccba98000000122244000000122244063333336443b44444444444414444144012224400bb3b3b00bb3bb000bbbbbb0000700006000022222200006
089abc1111cba98000000112224000000112224060000006443b44444424442444494444011222400b3bbb00b00b00b00bbb8bbb000070006000000000000006
89abc100001cba98000001222440000001222440600000064443b4444442444244444424012224400bbb0000000b0000bb8bbb4b000070006000000000000006
89abc100001cba980000011222400000011222406000000622223bb22222222294444444011222400b000000000b0000bbbbbbbb000700006000000000000006
11111111111111111111111111111111888877770bbb3bb3bbbbbb3bbbbbbb3000000000000000000000000000000000001000001000070000700c0000000c00
1666666166666666166666666666666188887777bbbbbbbbbbbbbbbbb3bbbbbb0000000000000000000000000000000000000000007000000c000000c0700000
16d555516d55555516d555556d55555188887777bbb333bb33b33bb3bb3bb33b0000000000000000000000000000000000000700000000700000000700000007
1655555165555555165555556555555188887777b332223b223223323323322b0000000000000000000000000000000007000000070707000070000000000700
1111111111111111111111111111111188887777222944234424e22422422f420000000000000000000000000000000000707070c77777700777070007777770
166661666666166666616666666166618888777724444a42494444444a4444420000000000000000000000000000000007777777777c77c7c77777c07777c777
16d5516d555516d555516d5555516d518888777702414444444a44f444c44420000000000000000000000000000000007c77c7c777777c77777777777c777777
16555165555516555551655555516551800870070022222222222222222222000000000000000000000000000000000077c77c77777777777c777777777777c7
4444444444444444000000000005600007000700566666660000056dd650000000000400099009900b330b300000004200100000100008000080090000000900
222222244222222200000000001006000700070056665666000010066001000000000040940f9049b22b32230000449400000000008000000900000090800000
22222224422222220555555000100d0007000700076507650000170dd0710000000000a9f009900908b288200004090200000800000000800000000800000008
1111111111111111000000500001d0000600060007650765000071d00d170000000004aa9049940f283882820240090008000000080808000080000000000800
000000000000000000000050000560005670567007650765055d00000000d550094049aa94900949288828222822088000808080988888800888080008888880
00000000000000000111110000100600567056700070007010d5000000005d014aa99aa90f0000f0028222202222878808888888888988989888889088889888
00000000000000000000000000100d006670566500700070100d00000000d00109aaaaa049400494002822000220888889889898888889888888888889888888
0000000000000000000000000001d000d66166650070007061d0000000000d16009aa900909f9909000220000000088088988988888888888988888888888898
6767676733333333000560000008800000bbbb00000000000122244000000000000000000000000000000000000000000666d66d666666d6666666d000000000
d6d6d6d62332323300056000008888000b8bbbb00000000001122240000000000000000000000000000000000000000066666666666666666d66666600000000
5d5d5d5d222222230005600008888880bbbbbb8b00003000012224400000000000000000000000000000000000000000666ddd66dd6dd66d66d66dd600000000
15151515222225220005600087777778bbbbbbbb030333000112224002444420000000000000000000000000000000006dd111d611d11dd1dd1dd11600000000
01010101222522220005600087777778bbb89bbb333333300122244000244200000777000000000000000000000000001115551d551551151151151100000000
00000000222222220005600008888880bbb88bbb33304333011222400002400000000000000000000000000000000000112551512555555d5515555100000000
000000005222222200056000008888000bbbbbb0040040400122244000024000000000000000000000000000000000001555d555555515555555d55100000000
00000000222222520005600000088000001442000400004012222244000240000000000000000000000000000000000001111111111111111111111000000000
00cccc0000bbbb002222222201155dd0dddddddd44444444444444440002400000ff0000000800000777400008e8000000000000000000000000000000000000
0c0000c00b0000b022222122015555d055d555d52222222222222222000240000ffff000007887007f74f0008e7e800000000000000000000000000000000000
c00cc00cb00bb00b2222222201155dd05d555d55222222222222222200024000ff2fff0007777f0077f77000e7e7e00000000000000000000000000000000000
c0c0000cb0b0b00b25222222015555d0555555551111d1111111111100024000ffff4f007ffff800494940008e7e800000000000000000000000000000000000
c0c0000cb0bbb00b2222222201155dd0551555150005600000000000000240000f4ff000f78887009494900008e8700000000000000000000000000000000000
c00cc00cb0b0b00b22122522015555d05155515500100600000000000002400000ff00008877ff00094900000000070000000000000000000000000000000000
0c0000c00b0000b02222222201155dd01111111100100d00000000000002400000000000ffff0000049400000000007000000000000000000000000000000000
00cccc0000bbbb0022222222015555d0111111110001d00000000000000240000000000000000000009000000000000700000000000000000000000000000000
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
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888777777888eeeeee888eeeeee888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88ee888ee88ee888ee88ee8e8ee88778887788ee8eeee88ee888ee88888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8eeeee8ee8eeeee8ee8eee8e8ee8777877778eee8eeee8eeeee8ee88888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8eee888ee8eeee88ee8eee888ee8777888778eee888ee8eeeee8ee88e8e888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8eee8eeee8eeeee8ee8eeeee8ee8777778778eee8e8ee8eeeee8ee88888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8eee888ee8eee888ee8eeeee8ee8777888778eee888ee8eeeee8ee888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888
111111111e111e111e111e111111161616111616161616111616111116111616161116111616161116161161161116161616166617771c111c1c1c111c111c11
111111111ee11e111eee1ee11111166616111666166616611661111116611666161116111666161116661161166116161661161611111cc11ccc1c111ccc1cc1
111111111e111e11111e1e111111161116111616111616111616111116111616161116111611161116161161161116161616161617771c111c1c1c11111c1c11
111111111eee1eee1ee11eee1111161116661616166616661616117116111616166616661611166616161161161116611616161611111c111c1c1ccc1cc11ccc
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1111166616111666161616661666111116661666161116111666161116661666166611661666166611111eee1e1e1eee1ee11111111111111111
111111e11e1111111616161116161616161116161111161116161611161116161611161611611611161616161666111111e11e1e1e111e1e1111111111111111
111111e11ee111111666161116661666166116611111166116661611161116661611166611611661161616611616111111e11eee1ee11e1e1111111111111111
111111e11e1111111611161116161116161116161111161116161611161116111611161611611611161616161616111111e11e1e1e111e1e1111111111111111
11111eee1e1111111611166616161666166616161171161116161666166616111666161611611611166116161616111111e11e1e1eee1e1e1111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616111666166616661166166616661666166616661666111111111cc1111111111111111111111111111111111111111111111111111111111111
111111111616161116161161161116161616166611611161166616111171177711c1111111111111111111111111111111111111111111111111111111111111
111111111666161116661161166116161661161611611161161616611777111111c1111111111111111111111111111111111111111111111111111111111111
111111111611161116161161161116161616161611611161161616111171177711c1111111111111111111111111111111111111111111111111111111111111
11111111161116661616116116111661161616161161166616161666111111111ccc111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161116661616166616661111161611111666166616111611166616111666166616661166166616661111161611111ccc11111111111111111111
111111111616161116161616161116161111161617771611161616111611161616111616116116111616161616661111161611111c1c11111111111111111111
111111111666161116661666166116611111166611111661166616111611166616111666116116611616166116161111166617771ccc11111111111111111111
111111111611161116161116161116161111111617771611161616111611161116111616116116111616161616161111111611111c1c11111111111111111111
111111111611166616161666166616161171166611111611161616661666161116661616116116111661161616161171166611111ccc11111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661611166616161666166611111661161611111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116161611161616161611161611111616161617771c1c1111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661611166616661661166111111616166611111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111611161611161611161611111616111617771c1c1111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116111666161616661666161611711666166611111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616111666161616661666111116111666166116611666166111111ccc1ccc1c1c1ccc111111111111111111111111111111111111111111111111
111111111616161116161616161116161111161116161616161616111616177711c11c1c1c1c1c11111111111111111111111111111111111111111111111111
111111111666161116661666166116611111161116661616161616611616111111c11cc11c1c1cc1111111111111111111111111111111111111111111111111
111111111611161116161116161116161111161116161616161616111616177711c11c1c1c1c1c11111111111111111111111111111111111111111111111111
111111111611166616161666166616161171166616161616166616661666111111c11c1c11cc1ccc111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161116661616166616661111166616661611161116661661116611111ccc1ccc1c1111cc1ccc1111111111111111111111111111111111111111
111111111616161116161616161116161111161116161611161111611616161117771c111c1c1c111c111c111111111111111111111111111111111111111111
111111111666161116661666166116611111166116661611161111611616161111111cc11ccc1c111ccc1cc11111111111111111111111111111111111111111
111111111611161116161116161116161111161116161611161111611616161617771c111c1c1c11111c1c111111111111111111111111111111111111111111
111111111611166616161666166616161171161116161666166616661616166611111c111c1c1ccc1cc11ccc1111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161116661616166616661111116616111666166116661661116611111ccc1ccc1c1111cc1ccc1111111111111111111111111111111111111111
111111111616161116161616161116161111161116111161161611611616161117771c111c1c1c111c111c111111111111111111111111111111111111111111
111111111666161116661666166116611111161116111161161611611616161111111cc11ccc1c111ccc1cc11111111111111111111111111111111111111111
111111111611161116161116161116161111161616111161161611611616161617771c111c1c1c11111c1c111111111111111111111111111111111111111111
111111111611166616161666166616161171166616661666166616661616166611111c111c1c1ccc1cc11ccc1111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111666161116661666166611661666166616661666166616661711111116661666161116111666161116661666166611661666166611111666
111111e11e1111111616161116161161161116161616166611611161166616111171177716111616161116111616161116161161161116161616166611111611
111111e11ee111111666161116661161166116161661161611611161161616611117111116611666161116111666161116661161166116161661161611111661
111111e11e1111111611161116161161161116161616161611611161161616111171177716111616161116111611161116161161161116161616161611111611
11111eee1e1111111611166616161161161116611616161611611666161616661711111116111616166616661611166616161161161116611616161611711611
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661666161116111666161116661666166611661666166611111616111111111bbb1b111bbb11711cc11ccc16661611166616661666116616661666
1111111116111616161116111616161116161161161116161616166611111616117117771b111b111b1b171111c11c1c16161611161611611611161616161666
1111111116611666161116111666161116661161166116161661161611111666177711111bb11b111bb1171111c11c1c16661611166611611661161616611616
1111111116111616161116111611161116161161161116161616161611111116117117771b111b111b1b171111c11c1c16111611161611611611161616161616
1111111116111616166616661611166616161161161116611616161611711666111111111b111bbb1b1b11711ccc1ccc16111666161611611611166116161616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111666166616111611166616111666166616661166166616661111161617111111166616661611161116661611166616661666116616661666
111111e11e1111111611161616111611161616111616116116111616161616661111161611711777161116161611161116161611161611611611161616161666
111111e11ee111111661166616111611166616111666116116611616166116161111166611171111166116661611161116661611166611611661161616611616
111111e11e1111111611161616111611161116111616116116111616161616161111111611711777161116161611161116111611161611611611161616161616
11111eee1e1111111611161616661666161116661616116116111661161616161171166617111111161116161666166616111666161611611611166116161616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661666161116111666161116661666166611661666166611111616111111111ccc17171bbb1b111bbb117116111666161616661611166616661666
1111111116111616161116111616161116161161161116161616166611111616117117771c1111711b111b111b1b171116111611161616111611116111611666
1111111116611666161116111666161116661161166116161661161611111666177711111ccc17771bb11b111bb1171116111661161616611611116111611616
111111111611161616111611161116111616116116111616161616161111111611711777111c11711b111b111b1b111116111611166616111611116111611616
1111111116111616166616661611166616161161161116611616161611711666111111111ccc17171b111bbb1b1b171116661666116116661666116116661616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111177111111111111111111111111111111111
1111111116661666161116111666161116661666166611661666166611111666166611661666166616161661111117771cc11111111111111111111111111111
11111111161116161611161116161611161611611611161616161666111116161611161116161616161616161171177771c11111111111111111111111111111
11111111166116661611161116661611166611611661161616611616111116611661166616661666161616161777177111c11111111111111111111111111111
11111111161116161611161116111611161611611611161616161616111116161611111616111616166616161171111711c11111111111111111111111111111
1111111116111616166616661611166616161161161116611616161611711616166616611611161616661616111111111ccc1111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822882228222888888888888888888888888888888888888888882828222822282288882822282288222822288866688
82888828828282888888828282828828882882828882888888888888888888888888888888888888888882828282888288288828828288288282888288888888
82888828828282288888822282828828882882828222888888888888888888888888888888888888888882228222888288288828822288288222822288822288
82888828828282888888828282828828882882828288888888888888888888888888888888888888888888828882888288288828828288288882828888888888
82228222828282228888822282228288822282228222888888888888888888888888888888888888888888828882888282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
00000000000000000000000023230340030303030000000000030000000000000101000101014007070000000023034003030000001101010b0000000000111103030303030101010300000000000000010100002323000023000000000000000303000001000000200000000303030000000302010101000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000026000000140015150014002600000000000000000000000000000040424300530000530000000053000053004157000000000000000000000000000056400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000002600151500143a2600000000000000000000000000000040424300535200530000000053005253004100570000000000000000000000005600400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000260015150014000000000000000000000000000000000040424300530000530000000053000053004100005700000000000000000000560000000000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000454646464700000000000000260015150014000000000000000000000000000000005640424300530000530052000053000053004100000057000000000000000056000000000000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
4546470000000000000000000000000000000000000000260015150014000000000000000000000000000000560040424351500000530000000053000051504100000000570000000000005600000000400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000024362515153a14000024000000000000000000000056000040424300000000530000000053000000004100000000005176767676760000000000400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000065000000000000000000001400151500140000320000000000000000000000517676404243005200005300000000530000000041005c0000000000000000000000005c00400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000065650000000000000000001400151500140000320000000000000000000000000000404243000000005300000000530000000041757675000000000000000000007576754000000000000026000000000000004100000000000000000000000000000000002b0000000000002b00000000002b00
000000000000000000000000000000000000000000000014001515001400002400000000000000000000000000004042430000000053003e3f0053000000004153005300000000000000000000530053400000000000002600000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000045464647000000000000000000140015242514000032000000000000000000000000000040424300000000505050505050000000004153005300000000515000000000530053403500000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001400151500140000320035000000000000000000000000404243000000000000000000000000520041530053000000000000000000005300534000000000000000000000000000004100000000000000000000000000000000000000002b0000000000002b00000000
4546464700000000000000000000000000000000000024363625150014000024747400000000000000000000000040424300000052000000000000000000004151765000000000000000000000517650400000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000140015150014000000310000000063000000630000000040424300000000670052000067000000004100000067000000000000006700000000400000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
003c0000640000000000001f00003c000029003b000000143c15153b14543c003100002900620000006200540000404243000f005477000000007754000f004100000077004043000040417700000000403500000000003500000000000000410000000000000000000000000000000000000000000000000000000000000000
1012101210101012101012101012101010121012121010121012121210121012606060606060006800606060606060604141424242424242424242424242424242424242424242545442424242424242421212121212121212121212121212416161616161616161616161616161616127272727272727272727272727272727
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
0108000013100131000000000000111001110000000000000f1000f100000000e1000e100000000c1000c10000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c000000000c00000000
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
00 411e1d44

