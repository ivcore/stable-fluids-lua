--[[
This is an example of how to use solver.lua

This example works with Love2D
https://www.love2d.org/

This solver and demo is based on the code from 'Real-time Fluid Dynamics for Games' by Jos Stam.
http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
]]
solver = require "solver"

local N = 64
local N2 = N+2

function alloc(v)
  v = v or 0.0
  local t, size = {}, (N2)*(N2)
  for i=1, size do t[i] = v end
  return t
end

--Position, Speed, Density
local u, v, dens = alloc(), alloc(), alloc()
--Previous Position, Speed, Density
local u_prev, v_prev, dens_prev = alloc(), alloc(), alloc()

--Defaults from demo.c
local dt = 0.1
local diff = 0.0
local visc = 0.0
local force = 2
local source = 50.0
local scaleFactor = love.graphics.getWidth()/N
local dvel = 0

--Keep track of mouse and density added.
local iPrev,jPrev = 0,0
local xPrev, yPrev = 0,0
local totalDensity, densityCap = 0, 150

--Density Effect
local densityImageData = love.image.newImageData(N, N)
local quad = love.graphics.newQuad(0, 0, N*scaleFactor,N*scaleFactor,N*scaleFactor,N*scaleFactor)

local densityEffect = love.graphics.newShader("density.glsl")

function updateFluid()
  solver:vel_step (N, u, v, u_prev, v_prev, visc, dt)
  solver:dens_step (N, dens, dens_prev, u, v, diff, dt)
  dens_prev,u_prev,v_prev = alloc(),alloc(),alloc()
end

function mouseadddensity(x,y)
  local i, j = math.floor(x/scaleFactor), math.floor(y/scaleFactor)
  if  i < 1 or i > N or j < 1 or j > N then return end

  local index = ((i)+(N+2)*(j))

  if totalDensity  < densityCap then
    dens_prev[index] = source
    totalDensity = totalDensity + 1
  end

  iPrev,jPrev = i,j
end

function mouseaddvelocity(x,y)
  local i, j = math.floor(x/scaleFactor), math.floor(y/scaleFactor)
  if  i < 1 or i > N or j < 1 or j > N then return end

  local index = ((i)+(N+2)*(j))

  u[index] = force * (i-iPrev)
  v[index] = force * (j-jPrev)

  iPrev,jPrev = i,j
end

function love.update()

  --If left click, add density
  if love.mouse.isDown(1) then
    local xCur, yCur = love.mouse.getPosition()
    if math.sqrt((xCur - xPrev)^2 + (yCur - yPrev)^2) > 1 then
      mouseadddensity(xCur ,yCur)
    end
    xPrev, yPrev = xCur, yCur
  end

  --If right-click, add velocity
  if love.mouse.isDown(2) then
    local xCur, yCur = love.mouse.getPosition()
    if math.sqrt((xCur - xPrev)^2 + (yCur - yPrev)^2) > 2 then
      mouseaddvelocity(xCur ,yCur)
    end
    xPrev, yPrev = xCur, yCur
  end

  updateFluid()

  --There should be a better way to do this, but here we convert a table into an image.
  local value, index = 0, 0

  for i=1,N do
    for j=1,N do
      value = dens[i+N2*j] * 255
      if value > 255 then
        value = 255
      end
      densityImageData:setPixel(i-1,j-1,value,value,value,255)
    end
  end

  totalDensity = totalDensity - dt
end

function love.draw()
  love.graphics.setShader(densityEffect)

  -- Here we make a texture from the imageData and draw a fullscreen quad with that texture
  local img = love.graphics.newImage(densityImageData)
  love.graphics.draw(img,quad, 0, 0, 0, 1, 1, 0,0)

  --Unset the fragment shader so you can draw other stuff.
  love.graphics.setShader()
end
