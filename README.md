wapi
==============

wapi is a simple async HTTP library which uses LÖVE threads

![image](https://media.giphy.com/media/l0MYxXHK9yvD8yJNu/giphy.gif)

Setup
----------------
Require library and update it
```lua
local wapi = require "webapi"

function love.update(dt)
  wapi.update()
end
```

Make request
```lua
request = wapi.request({
  method = "GET",
  url = "http://jsonplaceholder.typicode.com/posts/1"
}, function (body, headers, code)

  print(body)

end)
```

Usage
----------------

```lua
wapi.request(args, callback)
```
args is a table containing request arguments. See [Lua HTTP support](http://w3.impa.br/~diego/software/luasocket/http.html)

```lua
wapi.update()
```
update all running requests

```lua
wapi.cancel(request)
```
cancel an active request
