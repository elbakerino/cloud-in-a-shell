core.register_service("static-server", "http", function(applet)
  local docroot
  local location
  local file
  local retval
  local response
  local extension

  if(applet.path == nil or applet.headers["x-lua-loadfile-docroot"] == nil or applet.headers["x-lua-loadfile-docroot"][0] == "") then
    retval = 500
    response = "Internal Server Error"
  else
    docroot = applet.headers["x-lua-loadfile-docroot"][0]
    location = applet.path
    if(location == "" or location == "/") then
      location = "/index.html"
    end
    file = io.open(docroot .. location, "r")
    if(file == nil) then
      retval = 404
      response = "File Not Found in Document Root: " .. location
    else
      retval = 200
      response = file:read("*all")
      file:close()
    end
  end

  extension = string.match(location, ".(%w+)$")
  if       extension == "css"  then applet:add_header("content-type", "text/css")
    elseif extension == "gif"  then applet:add_header("content-type", "image/gif")
    elseif extension == "htm"  then applet:add_header("content-type", "text/html")
    elseif extension == "html" then applet:add_header("content-type", "text/html")
    elseif extension == "ico"  then applet:add_header("content-type", "image/x-icon")
    elseif extension == "jpg"  then applet:add_header("content-type", "image/jpeg")
    elseif extension == "jpeg" then applet:add_header("content-type", "image/jpeg")
    elseif extension == "js"   then applet:add_header("content-type", "application/javascript; charset=UTF-8")
    elseif extension == "json" then applet:add_header("content-type", "application/json")
    elseif extension == "mpeg" then applet:add_header("content-type", "video/mpeg")
    elseif extension == "png"  then applet:add_header("content-type", "image/png")
    elseif extension == "txt"  then applet:add_header("content-type", "text/plain")
    elseif extension == "xml"  then applet:add_header("content-type", "application/xml")
    elseif extension == "zip"  then applet:add_header("content-type", "application/zip")
  end

  applet:set_status(retval)
  if(response ~= nil and response ~= "") then
    applet:add_header("content-length", string.len(response))
  end
  applet:start_response()
  applet:send(response)
end)
