local wapi = require("webapi")

--

function love.update(dt)
  wapi.update()
end

--

function love.draw()
  love.graphics.printf("press space to execute query", 0, 100, love.graphics.getWidth(), "center")
  
  if wapi.thread and wapi.thread:isRunning() then --if query is loading
    
    for i = 1, 6 do --little spinner
      love.graphics.circle("fill", love.graphics.getWidth()*.5 + math.cos(love.timer.getTime() * 5 + i * .4) * 40, 300 + math.sin(love.timer.getTime() * 5 + i * .4) * 40, 1 + i)
    end
    
  elseif result then --our content is ready
    
    love.graphics.printf(result, 100, 240, love.graphics.getWidth() - 200, "center")
    
  end
  
end

--

function love.keypressed(key)
  if key == "space" then
    
    wapi.request({
      method = "GET",
      url = "http://jsonplaceholder.typicode.com/posts/1"
    }, function (body, headers, code)
    
      result = body
    
    end)
    
  end
end