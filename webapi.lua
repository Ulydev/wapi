-- webapi.lua v0.1

-- Copyright (c) 2017 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local http = require("socket.http")
local ltn12 = require("ltn12")

local webapi = {
  prefix = 'WEBAPI_',
  queries = {}
}

if type(...) == "number" then
  
  require "love.timer"
  
  local i = ... --let's avoid the strange ".. ... .." syntax
  
  local args = love.thread.getChannel(webapi.prefix .. i .. '_ARGS'):pop()
  
  local body = {}
  args.sink = ltn12.sink.table(body)
  local r, c, h = http.request(args)

  love.thread.getChannel(webapi.prefix .. i .. '_RES'):push({ table.concat(body), h, c })
  
else
  
  local filepath = (...):gsub("%.", "/") .. ".lua"

  function webapi.request(args, callback)
    
    local thread = love.thread.newThread(filepath)
    
    local query = {
      thread = thread,
      callback = callback,
      index = #webapi.queries + 1,
      active = true
    }
    
    webapi.queries[query.index] = query
    
    love.thread.getChannel(webapi.prefix .. query.index .. '_ARGS'):push(args)
    thread:start(query.index)
    
    return query
  end
  
  function webapi.update()
    
    for i, query in pairs(webapi.queries) do
      
      if query.thread then
        if not query.thread:isRunning() then --either done, or error
          query.active = false
          
          local err = query.thread:getError()
          assert(not err, err)

          local result = love.thread.getChannel(webapi.prefix .. i .. '_RES'):pop()
          if result ~= nil then
            if query.callback then query.callback(unpack(result)) end
            love.thread.getChannel(webapi.prefix .. i .. '_RES'):push(nil)
          end
          
          webapi.queries[query.index] = nil
          
        end
      end
      
    end
    
  end
  
  function webapi.cancel(query)
    
    if query.thread and query.thread:isRunning() then
      
      --TODO
      query.callback = nil --let's just remove callback for now
      
    end
    
  end
  
  return webapi
  
end
