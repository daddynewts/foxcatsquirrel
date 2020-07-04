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

 delay=100

 enemyangle=0
 enemyapproach=0
 
 -- sfx
 intro_jingle = 6
 eat_sfx = 14
 death_sfx = 1
 jump_sfx = 0
 slide_sfx = 2
 skull_sfx = 3
 bonus_sfx = 13
 spring_sfx = 4
 ghost_sfx = 12
 menu_sfx = 10
 balloon_sfx = 13
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
 explode_amount = flr(10)

 splash={
  sp=92,
  x=304,
  y=112,
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
  
 -- v for vertical 
 vplatform={
  x=30,
  y=60,
  maxy=100,
  miny=10,
  spoffl=20,
  spoffr=21,
  sponl=22,
  sponr=23,
 }
 
 -- h for horizontal
 hplatform={
  x=168,
  y=70,
  maxy=100,
  miny=10,
  sp=24,
 }
  
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
  ghost={}
   ghost_sp=10
   ghost.x=0
   ghost.y=0
   ghost.orbit=false
   
  skull={}
   skull_sp=13
   skull.x=10
   skull.y=0
 --}
 
 foods={}
  food={
  x=x,
  y=y,
  h=8,
  w=8,
  r=16
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
 
 timededuction=0
  
end

function test_mode()
-- edit test parameters here
-- not in the main body!
-- sfx(-1)
 --music(-1) -- music off
 timegain=count -- default 12
 timeleft-=timededuction
 timededuction=0.1*(count/6) -- default 0.3
end

function test_ui()
 --print("ghosts: "..#ghost,cam_x+1,1,7)
 --print("skulls: "..#skull,cam_x+1,9,7)
 --print("approach: "..enemyapproach,cam_x+1,17,7) 
 --print("ghost x: "..ghost.x,cam_x+1,17,7)
 --print("skull.x: "..skull.x,cam_x+1,25,7)
 -- food hitbox
 -- rect(food.x-20,food.y-20,food.x+24,food.y+24,7)
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
 del(skull,skull)
 del(ghost,ghost)
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
 else if not btn(❎)
  and player.falling
  then player.gliding=false
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
 spr(player.sp,player.x,player.y,1,1,player.flp)
 draw_food()
 draw_fx()
 draw_bonus()
 draw_ui()
 if #ghost>=1 then
  draw_ghost()
 elseif #skull>=1 then
  draw_skull()
 end
 draw_balloon()
end

function draw_ui()

 --timeleft
 --print(""..timeleft,cam_x+1,1,7)
 
 -- angle
 -- print("approach: "..enemyapproach,cam_x+1,1,7)
 --test_ui()
  
 -- food coords
 --print(""..#foods,cam_x+1,1,7)
 --print(""..food.x ..food.y,cam_x+1,9,7)
 --print(""..food.x ..food.y,cam_x+food.x-4,food.y-7,7)
 
 -- enemy coordinates on ui
-- if #enemies>=1 then
--  print(""..flr(ghost.x),cam_x+1,16,1)
-- end
 
 --if #enemies==0 then
 -- print("no enemies here!",player.x,player.y-8,7)
 --else
 -- print("enemies: "..#enemies,player.x,player.y-8,7)
 --end

--for food in all (foods) do
 
-- if collide_map(food,"left",0)
--  or collide_map(food,"down",0)
--  or collide_map(food,"up",0)
--  or collide_map(food,"right",0)
-- attempt 1 - with /8
-- does not work!

--if  fget(mget(flr(food.x/8,food.y/8)),0) == true
-- or fget(mget(flr((food.x/8),(food.y+7)/8)),0) == true
-- or fget(mget(flr((food.x+7)/8,food.y/8)),0) == true
-- or fget(mget(flr((food.x+7)/8,(food.y+7)/8)),0) == true
--then
--  print("it works!", player.x, player.y-8,7)
-- else
--  print("it doesn't work!", player.x, player.y-8,7) 
-- end
--end

-- print("dx ="..player.dx,1,1,7)
 -- now all 0n the bottom!
 
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
 -- timeleft-=0.5 
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
 print("score: "..points,(cam_x+81),121,7)
 
  -- white outline
 --rect((cam_x),0,(127+(cam_x)),(127+(cam_x)),7)
 --rect((cam_x),0,(127+(cam_x)),119,7)
 rect((cam_x),119,(127+(cam_x)),127,7)
 
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
-->8
-- gimmicks

function level_gimmicks()

 -- moving platform: ⬆️+⬇️
 vplatform.y-=2*cos(t())
   
 if vplatform.y > player.y --4
 and vplatform.y < player.y+10 -- +12
  and vplatform.x > player.x-15 -- -15
  and vplatform.x < player.x+6
  and player.dy>0
   then player.vplatform=true
   else player.vplatform=false
  end
  
  if player.vplatform==true then
    player.y=vplatform.y-8
    vplatform.spoffl=vplatform.sponl
    vplatform.spoffr=vplatform.sponr
    player.dy=0
   -- player.dy+=2/gravity
    player.landed=true
    player.falling=false
  else if player.vplatform==false then
    vplatform.spoffl=20
    vplatform.spoffr=21
   end
   
  end
 
  -- moving platform: ⬅️+➡️  
 hplatform.x+=3*sin(t())
  
 if  hplatform.y > player.y -- -4
  and hplatform.y < player.y+8 -- +4
  and hplatform.x > player.x-6 -- 4
  and hplatform.x < player.x+6
   and player.dy>0
   then 
    player.y=hplatform.y-8
    player.x=hplatform.x+player.dx
    player.dy=0
    player.landed=true
    player.jumping=false
    player.falling=false
    player.gliding=false
   end

-- bungee
--if level==0 and
-- player.y>=80 then
--  player.dy-=2
-- end
end

-->8
-- grabbables

function level_food()
 
  if level==0 then
    for i=1,1 do    
     food={
      sprite=flr(rnd(food_count)+food_start),
      x=flr(rnd(80)+15),
      y=flr(rnd(80)+10),
    }
    add(foods,food)
    end
 end
  
 if level==1 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(90)+15),
    y=flr(rnd(80)+15),
   }
  add(foods,food)
 end
 end
 
  if level>=2 then
  for i=1,1 do    
   food={
    sprite=flr(rnd(food_count)+food_start),
    x=level*128+flr(rnd(90)+15),
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
    --if #enemies>=1 then
   --  orbit=false
   -- end
   end
  end
end

function add_foodpoints()
 points+=flr(10000/timeleft)
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
 bonus.y-=0.2*cos(t())
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
 --     del(enemies,skull)
 --     del(enemies,enemy)
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
  balloon.x=player.x
  balloon.y-=1
 end
end
-->8
-- levels

function draw_levels()
 
 -- sunny hills
 if level==0 then
  sky.colour=12 -- light blue
  circfill(99,134,80,11) -- far hill
  circ(99,134,80,7) -- far outline
  circfill(126,154,80,3) -- near hill
  circ(126,154,80,5) -- right outline
  circfill(30,174,110,3) -- near hill
  circ(30,174,110,1) -- left outline
  circfill(80,16,8,10) -- sun
  draw_clouds()
  spr(vplatform.spoffl, vplatform.x,vplatform.y)
  spr(vplatform.spoffr, vplatform.x+8,vplatform.y)
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
  sky.colour=1 -- dark blue
  --pal(6,5) -- pale -> dark grey
  pal(9,4) -- orange -> brown
  pal(8,2) -- red -> maroon
  pal(7,13) -- white -> blue-grey
  pal(11,3) -- pale -> dark green
  pal(15,4) -- peach -> brown
  pal(10,2) -- yellow -> maroon
  pal(12,1) -- pale -> dark blue
  pal(14,2) -- pink -> maroon
  spr(splash.sp,splash.x,splash.y)
  spr(splash.sp+1,splash.x+8,splash.y)
  spr(splash.sp,splash.x+16,splash.y)  
   splash.sp+=0.2
     if splash.sp>94 then
        splash.sp=92
     end
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
 
 -- rivets
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

 if btnp(❎) then
  sfx(menu_sfx)
  level_music()
  init_game()
  _update=update_game
  _draw=draw_game
 end
end

function init_levelover()
  music(-1)
  del(balloons,balloon)
  del(foods,food)
  --del(enemies,ghost)
  --del(enemies,skull)
  del(ghost,ghost)
  del(skull,skull)
  count=0
  level+=1
  timeleft=timeleft+(timegain*2)
  player.x=(level*128)+56
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
--	cls()
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
 sspr(0,80,60,8,cam_x+25,36,128,16)
 
 rectfill(cam_x+33,53,cam_x+93,59,0)
-- print("your score:".. points,33,54,0)
 print("your score:".. points,cam_x+34,54,7)
 
 rectfill(cam_x+23,108,cam_x+98,121,1)
 rect(cam_x+23,108,cam_x+98,121,12)
 
 print("press   to restart",cam_x+26,112,7)
 spr(145,cam_x+48,111)
end

function draw_youwin()
 cls()
 pal()
 rectfill(0,0,127,127,1)
 spr(2,61,70)
 print("you win the game!",32,36,7)
 print("score: "..points,32,44,7)
 print("press ❎ to start again",22,52,7)
end
-->8
-- enemies
-- skulls work! (when alone)
-- ghosts work! (when alone)

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
 --make_ghost()
 --make_skull()
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
 
 for i=1,level+1 do
    skull={
    x=cam_x-player.x,
    y=flr(64)-player.y,
   }
  add(skull,skull)
  sfx(skull_sfx)
 end
end

function make_ghost()
 for i=1,1 do
   ghost={
   x=cam_x-player.x,
   y=flr(64)-player.y,
   }
  add(ghost,ghost)
  sfx(ghost_sfx)
  ghost.orbit=false
 end
end

function move_skull() 

 --for skull in all(enemies) do
-- easy
  skull.x-=((skull.x/100)-(player.x/100))*(player.dx/count+(flr(level+1)))
  skull.y-=((skull.y/100)-(player.y/100))*(player.dy/count+(flr(level+1)))
 --end
end

function move_ghost()
 enemyapproach=atan2(food.x+4,ghost.y)
 enemyangle+=(3.141592654/enemyapproach)/180
 
 --atan2 gives angle of 
 --two points
 
 --end
  --if ghost.x<=cam_x
  -- then ghost.x=cam_x
  --end
  
  -- circular movement
  if ghost.x > food.x-20
  and ghost.x < food.x+24
  and ghost.y > food.y-20
  and ghost.y < food.y+24
   then ghost.orbit=true
   else ghost.orbit=false
  end
  
  -- circular movement!
  if ghost.orbit==false then
   ghost.x=player.x-10
   ghost.y=player.y-10
 --  ghost.x-=(ghost.x/100)-(food.x/100)
 --  ghost.y-=(ghost.y/100)-(food.y/100)
  elseif ghost.orbit==true then
   ghost.x=food.x-10*cos(angle)
   ghost.y=food.y-20*sin(angle)
 end
end

function collision_enemies()

 for enemy in all(enemies) do
 
  if  enemy.y > player.y-4
  and enemy.y < player.y+4
  and enemy.x > player.x-4
  and enemy.x < player.x+4 then
      del(enemies,enemy)
      sfx(1)
      init_gameover()  
  end
  
  --if  enemy.y > food.y-4
  --and enemy.y < food.y+4
  --and enemy.x > food.x-4
  --and enemy.x < food.x+4 then
  --    del(enemies,enemy)
  --    sfx(1)
  --    init_gameover()  
  --end
 end
end

function draw_skull()

 --for skull in all(enemies) do
  spr(skull_sp,skull.x,skull.y)
  
  if player.x>=skull.x then
   skull_sp=13
  else skull_sp=12
 --end
end
end

function draw_ghost()

 --for ghost in all(enemies) do
  spr(ghost_sp,ghost.x,ghost.y)
   
  if player.x>=ghost.x then
   ghost_sp=10
  else ghost_sp=11
  end
 --end
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
bbbbbbbb44444444bbbbbbbb4444444476666667766666677666666776666667dddddddd0000000000ff0000000800000777400008e800000000000000000000
23b239bb44444444bc32233b44444445d55555555555555dd55555555555555dd111111d000000000ffff000007887007f74f0008e7e80000000000000000000
2222225b444449443322223344444444d52222222222225dd5cccccccccccc5ddddddddd00000000ff2fff0007777f0077f77000e7e7e0000000000000000000
42242222454444442224422249444444d55555555555555dd55555555555555d0000000000000000ffff4f007ffff800494940008e7e80000000000000000000
444444224944444922494422489444440dddddddddddddd00dddddddddddddd000000000000000000f4ff000f78887009494900008e870000000000000000000
4444494444444444444444444484444400000000000000000000000000000000000000000000000000ff00008877ff0009490000000007000000000000000000
4444444444444444444444444444544400000000000000000000000000000000000000000000000000000000ffff000004940000000000700000000000000000
4944444444444944445444a444444944000000000000000000000000000000000000000000000000000000000000000000900000000000070000000000000000
7777777777777777011666777d6667709999999002999999000003b07999799999a99979000000000000000000088000000bb000000000000077b0000077b000
667666766676667601d6666766666c7049444ff929444494000003b09999999799999999000000b0007777000088780000b77b00000000000b17bb000b17bb00
6766676667666766011666d6666667709444966924444a440000bb0099a99999799f999f00000b0b07aaaa90088887800bbaa7b00077b000bbbbbbb0bbbbbbb0
666d66d6666d66d601d6666666d66c70444496f9244444440000bb00999999a9999999990b00b00b0aa44a90088887803bbaa7bb0b17bb00aabbb3b0aabbb3b0
66d66d6666d66d66011667dd6d66677044449ff924444444000003b09a999994994499a9b0b0b0000aaa4a900828888003bbbbb7bbbbbbb000ab330000ab3300
555555555555555501d66dd555d66c7044249ff924444244000003b04999994444444999b00b000009aaaa9008288880003bbb73aabb33b00000300000003000
0000000005111150011667d00116677044429ff92524442400000bb04499444444444449000b000000999900008288000003b73000ab33000000034000030000
00000000055555d001d66c7001d66c70222229900222222200003b004444444444444444000b0000000000000008800000003300033340000000003003340000
0116677001555dd07777777777777777012224400000000099993b9999999999c7cccc7c122222240000000300a0a00000000000000870000000000000000000
01d66c70011555d0667666766676667601122240033333304493b49444944494cccccccc01122240000bbb3000aaa00000000000008887000000000000000000
0116677001555dd06766676667666766012224403bbaabb34a3b4a4444444444ccc7ccc70122244000b3b3b00aa9aa000000b000002888006588888888888856
01d66c70011555d0666666666666666601122240fbabbabf443b444444444444cccccccc0112224000bb3bb000a9a000b00bb0b0000280006022288888822206
0116677001555dd066566656666666660122244063333336443b44444444444414444144012224400bb3b3b00bb3bb000bbbbbb0000700006000022222200006
01d66c70011555d065666566666666560112224060000006443b44444424442444494444011222400b3bbb00b00b00b00bbb8bbb000070006000000000000006
0116677001555dd0555555556566666601222440600000064443b4444442444244444424012224400bbb0000000b0000bb8bbb4b000070006000000000000006
01d66c70011555d01111111166666666011222406000000622223bb22222222294444444011222400b000000000b0000bbbbbbbb000700006000000000000006
11111111111111111111111111111111888877770bbb3bb3bbbbbb3bbbbbbb3000000000000000000cccc7c00000000000000000000000000000000000000000
1666666166666666166666661666666188887777bbbbbbbbbbbbbbbbb3bbbbbb00000077000000000cccc7c00000000000000000000000000000000000000000
16d555516d55555516d5555516d5555188887777bbb333bb33b33bb3bb3bb33b00077777777000000cc7ccc00000000000000000000000000000000000000000
1655555165555555165555551655555188887777b331113b113113313313311b00777777777776000cccccc00000000000000000000000000000000000000000
111111111111111111111111111111118888777711122213221221121121122406677777777660000cccccc00000000000000000000000000000000000000000
166661666666166666616666666166618888777711422221422222222222222400066666666000000c7cccc00000000000000000000000000000000000000000
16d5516d555516d555516d5555516d518888777701112222222222222222224000000000000000000c7cccc00000000000000000000000000000000000000000
165551655555165555516555555165518008700700111111222242224444440000000000000000000ccc7cc00000000000000000000000000000000000000000
4444444444444444000000000005600007000700566666660000056d0000000000000400099009900b330b300000004200000000000000000000000000000700
222222244222222200000000001006000700070056665666000010060000000000000040940f9049b22b3223000044940000000000000c000070000000700000
22222224422222220555555000100d0007000700076507650000170d00000000000000a9f009900908b288200004090200000700007000000000070000000070
1111111111111111000000500001d0005670567007650765000071d000000000000004aa9049940f283882820240090007000000000000700700000007070700
000000000000000000000050000560005670567007650765055d000000000000094049aa949009492888282228220880007070700707070000707070c7777770
00000000000000000111110000100600567056700070007010d50000000000004aa99aa90f0000f0028222202222878807777777777c7c700777777c777c77c7
00000000000000000000000000100d006665666500700070100d00000000000009aaaaa04940049400282200022088887c77c7c7c7c777777c77c77777777c77
0000000000000000000000000001d000666666650070007061d0000000000000009aa900909f9909000220000000088077c77c777777c7c777c777c777c77777
6767676733333333000560000008800000bbbb000000000001222440000000000000000000000000000000000000000000000000000000000000000000000700
d6d6d6d62332323300056000008888000b8bbbb00000000001122240000000000000000000000000000000000000000000000000000000000070000000700000
5d5d5d5d222222230005600008888880bbbbbb8b0000300001222440000000000000000000000000000000000000000000000000000000000000070000000070
151515152222252200056000877777783bbbbbbb0303330001122240024444200000000000000000000000000000000000000000000000000700000007070700
010101012225222200056000877777783bb89bbb33333330012224400024420000000000000000000000000000000000000000000000000000707070c7777770
0000000022222222000560000888888033b88bb33330433301122240000240000000000000000000000000000000000000000000000000000777777c777c77c7
00000000522222220005600000888800033bbb300400404001222440000240000000000000000000000000000000000000000000000000007c77c77777777c77
000000002222225200056000000880000023340004000040122222440002400000000000000000000000000000000000000000000000000077c777c777c77777
00cccc0000bbbb002222222201155dd0dddddddd0000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
0c0000c00b0000b022222122015555d055d555d50000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00b2222222201155dd05d555d550000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
c0c0000cb0b0b00b25222222015555d0555555550000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
c0c0000cb0bbb00b2222222201155dd0551555150000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
c00cc00cb0b0b00b22122522015555d0515551550000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
0c0000c00b0000b02222222201155dd0111111110000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
00cccc0000bbbb0022222222015555d0111111110000000000000000000240000000000000000000000000000000000000000000000000000000000000000000
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
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888882282288882288228882228228888888ff888888228888
888882888888888ff8ff8ff88888888888888888888888888888888888888888888888888888888888228882288822222288822282288888ff8f888888222888
88888288828888888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888ff888f888888288888
888882888282888ff8ff8ff888888888888888888888888888888888888888888888888888888888882288822888222222888888222888ff888f888822288888
8888828282828888888888888888888888888888888888888888888888888888888888888888888888228882288882222888822822288888ff8f888222288888
888882828282888ff8ff8ff8888888888888888888888888888888888888888888888888888888888882282288888288288882282228888888ff888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
555555e555566656655555e555555555555665666566555506600606000055555555555555555555565555665566566655506660666000055066606660000555
55555ee555555655655555ee55555555556555656565655500600606000055555555555555555555565556565656565655506060606000055060606060000555
5555eee555566655655555eee5555555556665666565655500600666000055555555555555555555565556565656566655506060606000055060606060000555
55555ee555565555655555ee55555555555565655565655500600006000055555555555555555555565556565656565555506060606000055060606060000555
555555e555566656665555e555555555556655655566655506660006000055555555555555555555566656655665565555506660666000055066606660000555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555566666577777566666566666555555588888888566666666566666666566666666566666666566666666566666666566666666555555555
55555665566566655565566575557565556565656555555588877888566666766566666677566777776566667776566766666566766676566677666555dd5555
5555656565555655556656657775756665656565655555558878878856667767656666776756676667656666767656767666657676767656677776655d55d555
5555656565555655556656657555756655656555655555558788887856776667656677666756676667656666767657666767657777777756776677655d55d555
55556565655556555566566575777566656566656555555578888887576666667577666667577766677577777677576667767567676767577666677555dd5555
55556655566556555565556575557565556566656555555588888888566666666566666666566666666566666666566666666567666667566666666555555555
55555555555555555566666577777566666566666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555005005005005005dd500566555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555565655665655555005005005005005dd5665665555555777777775dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5dddddddd555555555
555565656565655555005005005005005775665665555555777777775d55ddddd5dd5dd5dd5ddd55ddd5ddddd5dd5dd5ddddd5dddddddd5dddddddd555555555
555565656565655555005005005005665775665665555555777777775d555dddd5d55d55dd5dddddddd5dddd55dd5dd55dddd55d5d5d5d5d55dd55d555555555
555566656565655555005005005665665775665665555555777557775dddd555d5dd55d55d5d5d55d5d5ddd555dd5dd555ddd55d5d5d5d5d55dd55d555555555
555556556655666555005005665665665775665665555555777777775ddddd55d5dd5dd5dd5d5d55d5d5dd5555dd5dd5555dd5dddddddd5dddddddd555555555
555555555555555555005665665665665775665665555555777777775dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5dddddddd555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00c0000d0d00550000000000000000000000000000055000000000000000000000000000005507770000066600eee00ccc00d0d00555
55507070000000600e0000c0000d0d00550000000000000000000000000000055000000000000000000000000000005507070000000600e000000c00d0d00555
55507700000006600eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005507700000006600eee00ccc00ddd00555
5550707000000060000e00c0c0000d0055000000000000000000000000000005500000000000000000000000000000550707000000060000e00c000000d00555
55507770000066600eee00ccc0000d00550010001000100001000010000100055001000100010000100001000010005507770000066600eee00ccc0000d00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770707066600eee00ccc00ddd005507770707066600eee00c0000ddd0055000000000000000000000000000005500000000000000000000000000000555
55507000777000600e0000c000000d005507000777000600e0000c000000d0055000000000000000000000000000005500000000000000000000000000000555
55507700707006600eee00ccc00ddd005507700707006600eee00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
5550700077700060000e0000c00d0000550700077700060000e00c0c00d000055000000000000000000000000000005500000000000000000000000000000555
55507000707066600eee00ccc00ddd005507000707066600eee00ccc00ddd0055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055011111111111111111aaaaa1111105500000000000000000000000000000555
5550000000000000000000000000000055000000000000000000000000000005507771111166611eee1acaca1d1d105500000000000000000000000000000555
5550000000000000000000000000000055000000000000000000000000000005507171111111611e111acaca1d1d105500000000000000000000000000000555
5550000000000000000000000000000055000000000000000000000000000005507711111116611eee1accca1ddd105500000000000000000000000000000555
555000000000000000000000000000005500000000000000000000000000000550717111111161111e1aaaca111d105500000000000000000000000000000555
5550010001000100001000010000100055001000100010000100001000010005507771111166611eee1aaaca111d105500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055011111111111111111aaaaa1111105500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507700707066600eee00c0000ddd00550000000000000000000000000000055000000000000000000000000000005507770000066600eee00cc000d0d00555
55507070777000600e0000c000000d00550000000000000000000000000000055000000000000000000000000000005507070000000600e00000c000d0d00555
55507070707006600eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005507700000006600eee000c000ddd00555
5550707077700060000e00c0c00d000055000000000000000000000000000005500000000000000000000000000000550707000000060000e000c00000d00555
55507770707066600eee00ccc00ddd00550010001000100001000010000100055001000100010000100001000010005507770000066600eee00ccc0000d00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000017100000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000017710000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000017771000005500000000000000000000000000000555
555000000000000000000000000000005507770000066600eee00ccc00d0d005507770000066600eee001777710d005500000000000000000000000000000555
555000000000000000000000000000005507070000000600e0000c0000d0d005507070000000600e000017711d0d005500000000000000000000000000000555
555000000000000000000000000000005507700000006600eee00ccc00ddd005507700000006600eee0001171ddd005500000000000000000000000000000555
55500000000000000000000000000000550707000000060000e0000c0000d00550707000000060000e0000c0000d005500000000000000000000000000000555
555001000100010000100001000010005507770000066600eee00ccc0000d005507770000066600eee00ccc0000d005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500770707066600eee00ccc00d0d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507000777000600e0000c0000d0d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507000707006600eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550700077700060000e0000c0000d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500770707066600eee00ccc0000d00550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507700707066600eee00c0000ddd005507770000066600eee00c0000d0d0055000000000000000000000000000005500000000000000000000000000000555
55507070777000600e0000c000000d005507070000000600e0000c0000d0d0055000000000000000000000000000005500000000000000000000000000000555
55507070707006600eee00ccc00ddd005507700000006600eee00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
5550707077700060000e00c0c00d0000550707000000060000e00c0c0000d0055000000000000000000000000000005500000000000000000000000000000555
55507770707066600eee00ccc00ddd005507770000066600eee00ccc0000d0055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
00000000000000000000000023230381030303030303030300000000000003030101000001010007070000000023030302000101001101010b0000000000111103030303030101010000230023230000010100002323008023000000000000000303000001000000000000000000000000000302010100000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000040414300530000530000000053000053004100000000000000000000000000000000410000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002600000000000000003a0000000000000000000000000000000040414300535200530000000053005253004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000025362400000000000000000000000000000000000000000000000040414300530000530000000053000053004100000000000000000000000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000024000000000000000000000000000000000000000000000000000000005640414300530000530052000053000053004132320000000000323200000000003232410000000000000000000000000020230000000000000000000000000000000000000000000000000000000000000000
45464700000000000000000000454647000000000000000000000000000000000000000000000000000000005600404143515000005300000000530000515041000000000000001e1e00000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000003a000000250000000000000000000000560000404143000000005300000000530000000041000000000000001e1e00000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000065000000000000002536240000000000000000000000000000000000000000515151404143005200005300000000530000000041000000323200001e1e00000032320000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000065650000000000000000000000000000000000000000000000000000000000000000404143000000005300000000530000000041000000000000001e1e000000000000004100000000000000000000000000004100000000000000000000000000000000002b0000000000002b00000000002b00
000000000000003e3f000000000000003624000000000000000029000000002500000000003500000000000000004041430000000053003e3f00530000000041000000000000001e1e00000000000000410000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000045464647000000000000002600000000000000002524000000000000000074740000000000000000404143000000005050505050500000000041000000000035001e1e00350000000000410000000050000000005000000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404143000000000000000000000000520041000000000021201e1e202100000000004100000000212020202021000000004100000000000000000000000000000000000000002b0000000000002b00000000
45470000000000000000000000004547000000000000253636240000000000257474000000000000000000000000404143000000520000000000000000000041000000000031001e1e00310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003100000000630000006300000000404143000000006700520000670000000041000000000031001e1e00310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
003c000064000000000000193b003c000029003b000000003c00003b00543c003100002900620000006200540000404143000f005477000000007754000f0041000000000031001e1e00310000000000410000000031000000003100000000410000000000000000000000000000000000000000000000000000000000000000
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
00 57151416
01 181c4344
00 191c1844
00 1a1c5544
02 1b424344

