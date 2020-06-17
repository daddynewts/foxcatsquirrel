pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init + variables

function _init()

 delay=100
 
 angle=0
 approach=0
 
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
 
function rndb(low,high)
 return flr(rnd(high-low+1)+low)
end

 -- crumbs
 effects = {}

 -- effects settings
 explode_size = 1
 explode_amount = flr(10)

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
 
 level=0
 count=0
 points=0
 
 cam_x=level*128
 cam_y=0
  
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

 enemies={
  ghost={ ghost_sp=10, x=100 },
  skull={ skull_sp=13, x=10 }
 }
 
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
  
end

function test_mode()
-- edit test parameters here
-- not in the main body!
-- sfx(-1)
 --music(-1) -- music off
 timegain=count -- default 12
 timeleft-=0.1*(count/6) -- default 0.3
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
 del(enemies,skull)
 del(enemies,ghost)
 draw_food()
  _update = update_mainmenu
  _draw = draw_menu
end

function init_game()
 level_food()
 make_bonus()
 make_balloon()
 if count==5 then
  make_enemies()
-- elseif count==11 then
--  make_ghost()
--  make_skull()
 end  
 _update = update_game
 _draw = draw_game
end

function init_gameover()
  music(-1)
  sfx(death_sfx)
  _update = update_gameover
  _draw = draw_gameover
end

function update_game()
  test_mode()
  update_fx()
  player_update()
  --level_gimmicks()
  player_animate()
  collide_food()
  if #enemies>=1 then
   move_enemies()
   collision_enemies()
  end
  if #bonuses>=1 then
   collide_bonus()
--   move_bonus()
  end
  if #balloons>=1 then
   move_balloons()
   collide_balloon()
  end
  if timeleft >=78 then
   timeleft=78
  end
  if timeleft <= 2 then
   init_gameover()
 end
  if player.y>=127 then
   init_gameover()
 end
end

function update_gameover()
	music(-1)
 delay-=1
	if delay<=50 and	btnp(❎) then
	 _init()
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
   player.dy=-5.2 -- default 6
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
      player.dy=player.dy/1.3
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
 if btn(🅾️) then
  make_shockwave()
  end
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

function make_shockwave()
 for i=1,10 do
  circ(player.x+4,player.y,i,7)
  sfx(shockwave_sfx)
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
 spr(player.sp,player.x,player.y,1,1,player.flp)
 draw_food()
 draw_fx()
 draw_bonus()
 draw_ui()
 if #enemies>=1 then
  draw_enemies()
 end
 draw_balloon()
end

function draw_ui()

 --timeleft
 --print(""..timeleft,cam_x+1,1,7)
 
 -- angle
  print("approach: "..approach,cam_x+1,1,7)
 -- food hitbox
 -- rect(food.x-20,food.y-20,food.x+24,food.y+24,7)
 
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

function draw_youwin()
 cls()
 pal()
 rectfill(0,0,127,127,1)
 spr(2,61,70)
 print("you win the game!",32,36,7)
 print("score: "..points,32,44,7)
 print("press ❎ to start again",22,52,7)
end

function draw_clouds()
 cloud1.x+=cloud1.speed
	cloud2.x+=cloud2.speed
	cloud3.x+=cloud3.speed
 -- cloud 1 - each line a line
 line(cloud1.x+2,4,cloud1.x+4,4,7) 
 line(cloud1.x,5,cloud1.x+5,5,7)
	line(cloud1.x-2,6,cloud1.x+6,6,7)
	
	--cloud 2
	line(cloud2.x+1,16,cloud2.x+4,16,7)
	line(cloud2.x,17,cloud2.x+6,17,7)
	line(cloud2.x-1,18,cloud2.x+7,18,7)

 -- cloud 3
 line(cloud3.x-1,25,cloud3.x+5,25,7)
 line(cloud3.x,26,cloud3.x+7,26,7)

		 if cloud1.x>=cam_x+128 then
	  cloud1.x=cam_x-8
	  cloud1.y=rnd(flr(20))
  elseif cloud2.x>cam_x+168 then
   cloud2.x=cam_x-8
   cloud2.y=rnd(flr(20))
  elseif cloud3.x>cam_x+200 then
   cloud3.x=cam_x-(rnd(flr(20)))
   cloud3.y=rnd(flr(5))+20
 end
end
-->8
-- things to fix

-- enemy movement
-- enemies not dying after level 2
-- crumbs to match food colour
-- food spawns off-screen?
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
 
 
--   end
--  end
-- end
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
    if #enemies>=1 then
     ghost.orbit=false
    end
   end
  end
end

function add_foodpoints()
 points+=flr(10000/timeleft)
 timeleft+=timegain	 --default 25?
 count+=1
 del(foods,food)
 sfx(eat_sfx)
 crumb=pget(cam_x+(food.x+3),food.y+3)
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

function collide_bonus()
    
  for bonus in all(bonuses) do
   if  bonus.y > player.y-8
   and bonus.y < player.y+8
   and bonus.x+4 > player.x
   and bonus.x+4 < player.x+8 then
      points+=100
      del(foods,food)
      del(bonuses,bonus)
      del(enemies,ghost)
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
  circ(99,134,80,7)
  circfill(126,154,80,3) -- near hill
  circ(126,154,80,5)
  circfill(30,174,110,3) -- near hill
  circ(30,174,110,1)
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
  sky.colour=1 -- dark blue
  pal(6,5)
  pal(9,4)
  pal(8,2)
  pal(7,13)
  pal(11,3)
  pal(15,4)
  pal(10,2)
  pal(12,1)
  pal(14,2)
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
 
 -- castle
 if level==4 then
  pal()
 end 
end

function level_music()
 if level==0 then
  music(music_level1)
 elseif level==1 then
  music(music_level2)
 end
end



function level_gimmicks()

-- bungee
if level==0 and
 player.y>=80 then
  player.dy-=2
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
  --sfx(9)
  _init()
  init_game()
  --music(1) 
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
  del(enemies,ghost)
  del(enemies,skull)
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
 -- 8*8 "level over"
-- sspr(68,64,60,8,cam_x+32,42,60,8)
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
-->8
-- enemies
-- skulls work! (when alone)
-- ghosts work! (when alone)

function make_enemies()
 make_skull()
 make_ghost()
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
  add(enemies,skull)
  sfx(skull_sfx)
 end
end

function make_ghost()
 for i=1,level+1 do
   ghost={
   x=cam_x-player.x,
   y=flr(64)-player.y,
   }
  add(enemies,ghost)
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
 approach=atan2(food.x+4,ghost.y)
 angle+=(3.141592654/approach)/180
 
 --atan2 gives angle of 
 --two points
 
 --for ghost in all(enemies) do
  
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
   ghost.x-=(ghost.x/100)-(food.x/100)
   ghost.y-=(ghost.y/100)-(food.y/100)
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
    cam_x+x,         -- x
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
bbbbbbbb44444444bbbbbbbbbbbbbbbbbbbbbbbb444444400444444444444444bbbbbb0000bbbbbb00ff0000000800000777400008e800000000000000000000
23b239bb44444444b33223bbbc3333cbbc32233b44444440044444944444444533b3bbb00bbbdb330ffff000007887007f74f0008e7e80000000000000000000
4224225b4444494433244222333222333324423344444540044444444444444422b133bbbb339b22ff2fff0007777f0077f77000e7e7e0000000000000000000
44944422454444440244444422244420224444224444444004a44444494444444d22223bb3222224ffff4f007ffff800494940008e7e80000000000000000000
44444444494444490444944444444440444944444944444004444444489444444444423bb32944440f4ff000f78887009494900008e870000000000000000000
44444944444444440444444444444a40444444444444444004444444448444444444d4bbbb44444400ff00008877ff0009490000000007000000000000000000
4444444444444444045444944444444044444444444444400449444544445444f444443bb34444d400000000ffff000004940000000000700000000000000000
49444444444449440444444444944440445444a44444494004444444444449444444444334444444000000000000000000900000000000070000000000000000
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
11111111111111111111111111111111888877770bbb3bb3bbbbbb3bbbbbbb300000000000000000000000000000000000000000000000000000000000000000
1666666166666666166666661666666188887777bbbbbbbbbbbbbbbbb3bbbbbb0000007700000000000000000000000000000000000000000000000000000000
16d555516d55555516d5555516d5555188887777bbb333bb33b33bb3bb3bb33b0007777777700000000000000000000000000000000000000000000000000000
1655555165555555165555551655555188887777b331113b113113313313311b0077777777777600000000000000000000000000000000000000000000000000
11111111111111111111111111111111888877771112221322122112112112240667777777766000000000000000000000000000000000000000000000000000
16666166666616666661666666616661888877771142222142222222222222240006666666600000000000000000000000000000000000000000000000000000
16d5516d555516d555516d5555516d51888877770111222222222222222222400000000000000000000000000000000000000000000000000000000000000000
16555165555516555551655555516551800870070011111122224222444444000000000000000000000000000000000000000000000000000000000000000000
4444444444444444000000000005600007000700566666660000056d0000000000000400099009900b330b300000004200000000000000000000000000000000
222222244222222200000000001006000700070056665666000010060000000000000040940f9049b22b32230000449400000000000000000000000000000c00
22222224422222220555555000100d0007000700076507650000170d00000000000000a9f009900908b288200004090200000000000000000000070000700000
1111111111111111000000500001d0005670567007650765000071d000000000000004aa9049940f283882820240090000000000000000000700000000000070
000000000000000000000050000560005670567007650765055d000000000000094049aa94900949288828222822088000000000000000000070707007070700
00000000000000000111110000100600567056700070007010d50000000000004aa99aa90f0000f00282222022228788000000000000000007777777777c7c70
00000000000000000000000000100d006665666500700070100d00000000000009aaaaa049400494002822000220888800000000000000007c77c7c7c7c77777
0000000000000000000000000001d000666666650070007061d0000000000000009aa900909f99090002200000000880000000000000000077c77c777777c7c7
6767676733333333000560000008800000bbbb000000000001222440000000000000000000000000000000000000000000000000000000000000000000000700
d6d6d6d62332323300056000008888000b8bbbb00000000001122240000000000000000000000000000000000000000000000000000000000070000000700000
5d5d5d5d222222230005600008888880bbbbbb8b0000000001222440000000000000000000000000000000000000000000000000000000000000070000000070
151515152222252200056000877777783bbbbbbb0000300001122240000000000000000000000000000000000000000000000000000000000700000007070700
010101012225222200056000877777783bb89bbb03033300012224400000000000000000000000000000000000000000000000000000000000707070c7777770
0000000022222222000560000888888033b88bb33330403001122240000000000000000000000000000000000000000000000000000000000777777c777c77c7
00000000522222220005600000888800033bbb303330433301222440000000000000000000000000000000000000000000000000000000007c77c77777777c77
000000002222225200056000000880000023340004000040122222440000000000000000000000000000000000000000000000000000000077c777c777c77777
00cccc0000bbbb002222222201155dd0dddddddd00990000000800000777400008e8000000000000000000000000000000000000000000000000000000000000
0c0000c00b0000b022222122015555d055d555d509999000007887007f74f0008e7e800000000000000000000000000000000000000000000000000000000000
c00cc00cb00bb00b2222222201155dd05d555d559949990007777f0077f77000e7e7e00000000000000000000000000000000000000000000000000000000000
c0c0000cb0b0b00b25222222015555d055555555999949007ffff800494940008e7e800000000000000000000000000000000000000000000000000000000000
c0c0000cb0bbb00b2222222201155dd05515551509499000f78887009494900008e8700000000000000000000000000000000000000000000000000000000000
c00cc00cb0b0b00b22122522015555d051555155009900008877ff00094900000000070000000000000000000000000000000000000000000000000000000000
0c0000c00b0000b02222222201155dd01111111100000000ffff0000049400000000007000000000000000000000000000000000000000000000000000000000
00cccc0000bbbb0022222222015555d0111111110000000000000000009000000000000700000000000000000000000000000000000000000000000000000000
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
555555e555566656665555e555555555555665666566555506600666000055555555555555555555565555665566566655506660666000055066606660000555
55555ee555555656565555ee55555555556555656565655500600006000055555555555555555555565556565656565655506060606000055060606060000555
5555eee555566656565555eee5555555556665666565655500600666000055555555555555555555565556565656566655506060606000055060606060000555
55555ee555565556565555ee55555555555565655565655500600600000055555555555555555555565556565656565555506060606000055060606060000555
555555e555566656665555e555555555556655655566655506660666000055555555555555555555566656655665565555506660666000055066606660000555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555777775666665666665666665555555666666665666666665666666665666666665666666665666666665eeeeeeee566666666555555555
555556655665666555755775655565655565656565555555666776665666667665666666775667777765666677765667666665ee7eee7e566677666555dd5555
5555656565555655557757756665656665656565655555556676676656667767656666776756676667656666767656767666657e7e7e7e56677776655d55d555
5555656565555655557757756555656655656555655555556766667656776667656677666756676667656666767657666767657777777756776677655d55d555
555565656555565555775775656665666565666565555555766666675766666675776666675777666775777776775766677675e7e7e7e7577666677555dd5555
555566555665565555755575655565655565666565555555666666665666666665666666665666666665666666665666666665e7eeeee7566666666555555555
55555555555555555577777566666566666566666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555005dd500500500500500566555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555565655665655555005dd5005005005005665665555555dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd5dddddddd555555555
555565656565655555005dd5005005005665665665555555dddddddd5d55ddddd5dd5dd5dd5ddd55ddd5777775775dd5ddddd5dddddddd5dddddddd555555555
555565656565655555005dd5005005665665665665555555dddddddd5d555dddd5d55d55dd5dddddddd5777755775dd55dddd55d5d5d5d5d55dd55d555555555
555566656565655555005dd5005665665665665665555555ddd55ddd5dddd555d5dd55d55d5d5d55d5d5777555775dd555ddd55d5d5d5d5d55dd55d555555555
555556556655666555005dd5665665665665665665555555dddddddd5ddddd55d5dd5dd5dd5d5d55d5d5775555775dd5555dd5dddddddd5dddddddd555555555
555555555555555555005775665665665665665665555555dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd5dddddddd555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600e0000cc000d0d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507000000060600e00000c000d0d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507700000060600eee000c000ddd00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507000000060600e0e000c00000d00550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00ccc0000d00550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000010000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001171010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000177100000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000177710000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55501111111111177771a11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550111111111117711aa11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550111111111111171aa11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550111111111111aaaaa11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550111111111111aaaaa11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550121112111211aa2aa11211112110550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
5550111111111111aaaaa11111111110550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
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
40000000000000000000000023230381030303030303030303030000000000000101000001010007070000000023030302000101001101010b0000000000111103030303030101010000232323230000010100002323008023000000000000000303000001000000000000000000000000000302030000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000040434300530000530000000053000053004000000000000000303000000000000000300000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002600000000000000003a0000000000000000000000000000000040434300535200530000000053005253004000000000000000303000000000000000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000025362400000000000000000000000000000000000000000000000040434300530000530000000053000053004000000000000000303000000000000000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000024000000000000000000000000000000000000000000000000000000005640434300530000530052000053000053004032320000000000303000000000003232300000000000000000000000000020230000000000000000000000000000000000000000000000000000000000000000
3724000000000000000000000000253700000000000000000000000000000000000000000000000000000000560040434351500000530000000053000051504000000000000000303000000000000000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
0000000000000000004546470000000000000000000000000000003a00000025000000000000000000000056000040434300000000530000000053000000004000000000000000303000000000000000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
0000000000000000000039006500000000000000253624000000000000000000000000000000000000000051515140434300520000530000000053000000004000000032320000303000000032320000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
00000000000000000000340000000000000000000000000000000000000000000000000000000000000000000000404343000000005300000000530000000040000000000000003030000000000000003000000000000000000000000000003000000000000000000000000000000000002b0000000000002b00000000002b00
000000004546470000003400000000003624000000000000000029000000002500000000003500000000000000004043430000000053003e3f0053000000004000000000000000303000000000000000300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000
0000000000390000000034000000000000260000000000000000252400000000000000002020000000000000000040434300000000505050505050000000004000000000003500303000350000000000300000000050000000005000000000300000000000000000000000000000000000000000000000000000000000000000
003c0000003400000000340000003c00000000000000000000000000000000000000000000000000000000000000404343000000000000000000000000520040000000000021203030202100000000003000000000212020202021000000003000000000000000000000000000000000000000002b0000000000002b00000000
4546470000340000000034000045464700000000000025363624000000000025212000000000000000000000000040434300570052000000000000000057004000000000003100303000310000000000300000000031000000003100000000300000000000000000000000000000000000000000000000000000000000000000
0039000000340000000034000000390000000000000000000000000000000000306200000063000000630000000040434300570000000052000000000057004000000000003100303000310000000000300000000031000000003100000000300000000000000000000000000000000000000000000000000000000000000000
006600000066003e3f0066003b0066000029003b000000003c00003b00543c003062002900620000006200540000404343000f005400000000000054000f004000000000003100303000310000000000300000000031000000003100000000300000000000000000000000000000000000000000000000000000000000000000
10141014101010141010141010141010101410141410101410141414101410186060606060606e5f6f606060606060604041424242424242424242424242424300000035003100303000310035000000300000500031000000003100500000306161616161616161616161616161616127272727272727272727272727272727
1117111111171117111111111711111700000000000000000000000000000000007575757575494949757575757575343333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434343434343434343434343434343434000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010e00000c0430c043000002462500000246000c0430c0430c000246250000000000000000c0430c4000c0432a303042003b3003b3003b300007052f705247052f705007052f705007052f705007052f70500705
010e00002f5642a562005022756200502005022556427562005022a5620050222502005022f564005022f56400500005022f11400500005022f11400500245022f11400500005042f11400500005000050000500
010e00001201012011120150b0100b0110b0150f0100f0110f0151201012011120101201523014000000b01517000170001700017000240002f000000002f0002f000240002f000000002f000000000000000000
010e00001b3111b314003021e31200302003021731417315003001b3141b30000300003002a3242f3002f3242f30000300003002f30000300003002f30000300243002f30000300003002f300003000030000300
__music__
01 48050750
00 48050807
00 47060750
02 07050650
01 52111044
00 13111044
00 17151416

