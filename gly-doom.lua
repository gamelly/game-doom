local game = {
    player = {
        x = 3, --start location
        y = 3, --start location
        angle = 0, -- start angle
        fov = math.pi / 3,
        speed = 5,
        turn_speed = 1.5
    },
    map = {
        width = 8,
        height = 8,
        grid = {
            1,1,1,1,1,1,1,1,
            1,0,0,0,0,0,0,1,
            1,0,1,0,1,0,0,1,
            1,0,1,0,1,0,0,1,
            1,0,0,0,0,1,0,1,
            1,0,1,0,0,0,0,1,
            1,0,0,0,0,0,0,1,
            1,1,1,1,1,1,1,1,
        }
    },
    -- Rendering properties
    num_rays = 100,
    max_distance = 20,
    ray_step = 0.1
}

function love.load()
    game.player.x = 3
    game.player.y = 3
    game.player.angle = 0

    -- calculate ray step
    game.ray_angle_step = game.player.fov / game.num_rays
end

function getMap(x, y)
    x, y = math.floor(x), math.floor(y)
    if x < 1 or x > game.map.width or y < 1 or y > game.map.height then
        return 1
    end
    return game.map.grid[(y - 1) * game.map.width + x]
end

function castRay(angle)
    local dist = 0
    local hit = false
    local hitX, hitY
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    
    while not hit and dist < game.max_distance do
        dist = dist + game.ray_step
        local x = game.player.x + cosA * dist
        local y = game.player.y + sinA * dist
        
        if getMap(x, y) ~= 0 then
            hit = true
            hitX, hitY = x, y
        end
    end
    return dist, hitX, hitY
end

function love.update(dt)
    local speed = game.player.speed * dt
    local new_x = game.player.x
    local new_y = game.player.y
    
    if love.keyboard.isDown("up") then
        new_x = game.player.x + math.cos(game.player.angle) * speed
        new_y = game.player.y + math.sin(game.player.angle) * speed
    elseif love.keyboard.isDown("down") then
        new_x = game.player.x - math.cos(game.player.angle) * speed
        new_y = game.player.y - math.sin(game.player.angle) * speed
    end
    
    -- check collision before update pos
    if getMap(new_x, game.player.y) == 0 then
        game.player.x = new_x
    end
    if getMap(game.player.x, new_y) == 0 then
        game.player.y = new_y
    end
    
    if love.keyboard.isDown("left") then
        game.player.angle = game.player.angle - game.player.turn_speed * dt
    elseif love.keyboard.isDown("right") then
        game.player.angle = game.player.angle + game.player.turn_speed * dt
    end
    
    if love.keyboard.isDown("r") then --reset game
        love.load() 
    end
end

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- sky
    love.graphics.setColor(0.4, 0.4, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight/2)

    --ground
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, screenHeight/2, screenWidth, screenHeight/2)
    
    -- walls
    for i = 0, game.num_rays do
        local angle = game.player.angle - (game.player.fov / 2) + (i * game.ray_angle_step)
        local dist = castRay(angle)
        local lineHeight = math.min(screenHeight, 1000 / (dist + 0.0001))
        local x = (i / game.num_rays) * screenWidth
        
        -- change brightness
        local brightness = math.max(0.2, 1 - dist / game.max_distance)
        love.graphics.setColor(brightness, brightness, brightness)
        love.graphics.rectangle("fill", x, (screenHeight - lineHeight) / 2, 
            screenWidth / game.num_rays + 1, lineHeight)
    end
end