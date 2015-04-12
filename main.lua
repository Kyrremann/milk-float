function love.load()
   MENU = 1
   GAME = 2
   CRASH = 3
   WINNER = 4
   state = MENU

   help_text = "Drive with the 'arrows', and deliver milk from" ..
      " the left side with 'space'!"
   credits = "\"Milk float - Liverpool (modified background)\" by Tagishsimon"
   intro = love.graphics.newImage("images/milk_float.jpg")

   screen_height = love.graphics.getHeight()
   screen_width = love.graphics.getWidth()
   intro_x = (screen_width - intro:getWidth()) / 2

   crash_1 = love.graphics.newImage("images/crash_1.jpg")
   crash_2 = love.graphics.newImage("images/crash_2.jpg")
   crash_3 = love.graphics.newImage("images/crash_3.jpg")
   
   crash_1_x = (screen_width - crash_1:getWidth()) / 2
   crash_2_x = (screen_width - crash_2:getWidth()) / 2
   crash_3_x = (screen_width - crash_3:getWidth()) / 2

   local fontUrl = "fonts/kenpixel_square.ttf"
   fontMini = love.graphics.newFont(fontUrl, 11)
   fontSmall = love.graphics.newFont(fontUrl, 16)
   fontBig = love.graphics.newFont(fontUrl, 36)

   road = {
      love.graphics.newImage("images/road_1.png"),
      love.graphics.newImage("images/road_2.png"),
      love.graphics.newImage("images/cross.png"),
      love.graphics.newImage("images/turn_1.png"),
      love.graphics.newImage("images/turn_2.png"),
      love.graphics.newImage("images/house_1.png"),
      love.graphics.newImage("images/turn_3.png")
   }
   last_driver = -1
end

function init_game()
   player = {
      image = {
	 love.graphics.newImage("images/truck_1.png"),
	 love.graphics.newImage("images/truck_2.png"),
	 love.graphics.newImage("images/truck_3.png"),
	 love.graphics.newImage("images/truck_4.png")
      },
      index = 3,
      x = 32,
      y = 8,
      just_moved = false,
      last_tile = 1,
      deliveries = 0,
      delivered = {},
      points = 0,
      draw = function() return player.image[player.index] end
   }
   map = require "level_1"
   crash_type = 1
   math.randomseed(os.time())
   local id = last_driver
   while last_driver == id do
      id = math.random(16)
   end
   last_driver = id
   driver = love.graphics.newImage("images/driver_" .. id .. ".png")
   houses = 18
end

function love.update(dt)
   if state == MENU then
   elseif state == GAME then
      if player.just_moved then
	 local tile = get_tile()
	 if tile then
	    if tile == 0 then
	       state = CRASH
	       crash_type = 1
	    end
	    if tile == 6 then
	       state = CRASH
	       crash_type = 2
	    end
	 else
	    state = CRASH
	    crash_type = 1
	 end
	 player.just_moved = false
      end
      if player.deliveries == houses then
	 state = WINNER
	 generate_winner_screen()
      end
   end
end

function generate_winner_screen()
   winner = love.graphics.newImage("images/winner_" .. math.random(7) .. ".jpg")
   winner_x = (screen_width - winner:getWidth()) / 2   
end

function get_tile()
   local tx = player.x / 16
   local ty = (player.y / 8) + 1
   if map[ty] and map[ty][tx] then
      return map[ty][tx]
   end
   return nil
end

function love.draw()
   if state == MENU then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(intro, intro_x, 0)
      love.graphics.setFont(fontBig)
      love.graphics.printf("Press enter to deliver milk!", 
			   0, 500,
			   screen_width, "center")
      love.graphics.setFont(fontMini)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(credits,
			  intro_x + 5, intro:getHeight() - 20)
      love.graphics.setColor(255, 255, 255)
      love.graphics.setFont(fontSmall)
      love.graphics.printf(help_text, 
			   0, 550,
			   screen_width, "center")
   elseif state == GAME then
      love.graphics.setColor(255, 255, 255)
      for y=1, #map do
	 for x=1, #map[y] do
	    local tile = map[y][x]
	    if tile ~= 0 then
	       love.graphics.draw(road[tile], 16 * x, 8 * y)
	    end
	 end
      end      
      love.graphics.draw(player.draw(), player.x, player.y)
      
      -- sidebar
      love.graphics.draw(driver, 400, 25)
      love.graphics.setFont(fontMini)
      love.graphics.print("Deliveries: " .. player.deliveries .. "/" .. houses, 
			  435, 23)
      love.graphics.print("Points: " .. player.points, 435, 38)
   elseif state == CRASH then
      love.graphics.setColor(255, 255, 255)
      if crash_type == 1 then
      love.graphics.draw(crash_1, crash_1_x, 0)
      elseif crash_type == 2 then
      love.graphics.draw(crash_2, crash_2_x, 0)
      elseif crash_type == 3 then
      love.graphics.draw(crash_3, crash_3_x, 0)
      end
   elseif state == WINNER then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(winner, winner_x, 0)
      love.graphics.setFont(fontBig)
      love.graphics.printf("You are a winner!", 
			   0, 450,
			   screen_width, "center")
      love.graphics.setFont(fontSmall)
      love.graphics.printf("Daily earnings £" .. player.points, 
			   0, 500,
			   screen_width, "center")
   end
end

function love.keypressed(key)
   if state == MENU then
      if key == 'return' then
	 state = GAME
	 init_game()
      elseif key == 'escape' then
	 love.event.push('quit')
      end
   elseif state == GAME then
      if key == 'escape' then
	 state = MENU
	 return
      elseif key == ' ' then
	 deliver_milk()
	 return
      end
      
      player.last_tile = get_tile()
      if key == 'up' then
	 player.index = 1
	 player.x = player.x - 16
	 player.y = player.y - 8
	 player.just_moved = true
      elseif key == 'down' then
	 player.index = 3
	 player.x = player.x + 16
	 player.y = player.y + 8
	 player.just_moved = true
      elseif key == 'right' then
	 player.index = 2
	 player.x = player.x + 16
	 player.y = player.y - 8
	 player.just_moved = true
      elseif key == 'left' then
	 player.index = 4
	 player.x = player.x - 16
	 player.y = player.y + 8
	 player.just_moved = true
      end
   elseif state == CRASH then
      if key then
	 state = MENU
      end
   elseif state == WINNER then
      if key then
	 state = MENU
      end
   end
end

function deliver_milk()
   local x = player.x / 16
   local y = (player.y / 8) + 1
   local delivered_milk = false
   if map[y] and map[y][x] then
      if player.index == 3 or player.index == 1 then
	 x = x + 1
	 y = y - 1
	 if map[y] and map[y][x] then
	    local tile = map[y][x]
	    if tile == 6 then
	       if not has_delivered_milk_before(y, x) then
		  delivered_milk = true
		  if not player.delivered[y] then
		     player.delivered[y] = {}
		  end
		  player.delivered[y][x] = true
	       end
	    end
	 end
      end
   end

   if delivered_milk then
      player.deliveries = player.deliveries + 1
      player.points = player.points + 12.5
   else
      player.points = player.points - 15
   end
end

function has_delivered_milk_before(y, x)
   if not player.delivered[y] then
      return false
   end
   return player.delivered[y] and player.delivered[y][x]
end
