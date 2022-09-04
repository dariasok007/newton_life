local love = require 'love'
local color = require 'color'
local slider = require 'slider'

local w = 1024
local h = 800

local function gen_points(n)
    local points = {}
    for i = 1, n do
        local x = math.random(w)
        local y = math.random(h)
        local p = { x = x, y = y,  vx = 0, vy = 0, c = 0 }
        points[#points + 1] = p
    end
    return points
end
local all_points = {}
local red = {} 
local sliders = {}
local n_red = 1000
local n_blue = 1000

local function reset_points()
    red = gen_points(n_red)
    blue = gen_points(n_blue)
    all_points = { red, blue }
end

local function gen_sliders()
    local red = slider.newSlider(100, 100, 100, n_red, 0, 5000,
        function (v)
            if v ~= n_red then
                n_red = v
                reset_points()
            end
        end,
        {   width=28,
            orientation='horizontal',
            track='rectangle',
            knob='rectangle'
        }
    )
    sliders[#sliders + 1] = red
end

function love.load()
    love.window.setFullscreen(true, "desktop")
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()
    reset_points()
    gen_sliders()
end
 

function love.keypressed(k)
    if k == 'escape' then
       love.event.quit()
    end
end

function rule(ax, bx, g, r0)
    local g = - g / 100
    for i, a in ipairs(ax) do
        local fx = 0
        local fy = 0
        local count = 0
        for _, b in ipairs(bx) do
            local dx = a.x - b.x
            local dy = a.y - b.y
            local d = math.sqrt(dx * dx + dy * dy)
            if d < r0 and d > 0 then
                fx = fx + dx / d
                fy = fy + dy / d
                count = count + 1
            end
        end
        a.c = count / #bx
        a.vx = 0.5 * (a.vx + fx * g)
        a.vy = 0.5 * (a.vy + fy * g)
        a.x = a.x + a.vx
        a.y = a.y + a.vy
        if a.x > w - 10 and a.vx > 0 then
            a.vx = - a.vx
        end
        if a.x < 10 and a.vx < 0 then
            a.vx = - a.vx
        end
        if a.y > h - 10 and a.vy > 0 then
            a.vy = - a.vy
        end
        if a.y < 10 and a.vy < 0 then
            a.vy = - a.vy
        end
    end
end


local colors = {{0.9, 1.0}, {0.15, 0.25}}

function love.update()
    for _, s in ipairs(sliders) do
        s:update()
    end
    rule(red, red, 10, 50)
    rule(blue, blue, 5, 75)
    rule(red, blue, -10, 25)
    rule(blue, red, 5, 100)
end

function love.draw()
    for i, px in ipairs(all_points) do
        local cra, crb = colors[i][1], colors[i][2]
        for _, p in ipairs(px) do
            local c = color.interpolate(color.turbo, cra + (crb - cra) * p.c)
            love.graphics.setColor(c[1], c[2], c[3])
            love.graphics.circle('fill', p.x, p.y, 5)
        end
    end
    love.graphics.setColor(1, 1, 1)
    for _, s in ipairs(sliders) do
        s:draw()
    end
end