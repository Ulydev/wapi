-- webapi.lua v0.1

-- Copyright (c) 2017 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local http = require("socket.http")
local ltn12 = require("ltn12")

local webapi = {
  prefix = 'WEBAPI',
  thread = nil,
  callback = nil
}

if ... == true then
  
  local args = love.thread.getChannel(webapi.prefix .. '_ARGS'):pop()
  
  local body = {}
  args.sink = ltn12.sink.table(body)
  local r, c, h = http.request(args)

  love.thread.getChannel(webapi.prefix .. '_RES'):push({ table.concat(body), h, c })
  
else
  
  local filepath = (...):gsub("%.", "/") .. ".lua"

  function webapi.request(args, callback)
    
    local thread = love.thread.newThread(filepath)
    
    love.thread.getChannel(webapi.prefix .. '_ARGS'):push(args)
    thread:start(true)
    webapi.thread = thread
    webapi.callback = callback
    
  end
  
  function webapi.update()
    
    if webapi.thread then
      if not webapi.thread:isRunning() then
        
        local err = webapi.thread:getError()
        assert(not err, err)

        local result = love.thread.getChannel(webapi.prefix .. '_RES'):pop()
        if result ~= nil then
          webapi.callback(unpack(result))
          love.thread.getChannel(webapi.prefix .. '_RES'):push(nil)
        end
        
      end
    end
    
  end
  
  return webapi
  
end
