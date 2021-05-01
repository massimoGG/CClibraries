--[[
    This library allows to create simple CC GUIs
    in an OOP approach.
    TODO:
     - Everything lol
]]
local libgui = {
    padding_horizontal = 1,
    maxx = 0, maxy=0,
    themes = {
        selectedTheme = "dark",
        light = {
            backgroundColor = colors.white,
            textColor       = colors.black,
            menubar = {
                backgroundColor = colors.lightGray,
            },
            readLine = {
                backgroundColor = colors.black,
                textColor       = colors.white,
                shadowColor     = colors.gray,
            },
            text = {
                backgroundColor = colors.white,
                textColor       = colors.black,
            },
            button = {
                backgroundColor = colors.lightGray,
                textColor       = colors.red,
            },
        },
        dark = {
            backgroundColor = colors.black,
            textColor = colors.white,
            menubar = {
                backgroundColor = colors.lightGray,
            },
            readLine = {
                backgroundColor = colors.black,
                textColor       = colors.white,
                shadowColor     = colors.gray,
            },
            text = {
                backgroundColor = colors.black,
                textColor       = colors.white,
            },
            button = {
                backgroundColor = colors.lightGray,
                textColor       = colors.black,
                selectedColor   = colors.white,
            },
        }
    }
}
local log = {
  filename = "log",
  filestream = 0,
}
function log.log(tag, str)
  if (log.filestream == 0) then
    log.filestream = io.open(log.filename, "a+")
  end
  log.filestream:write("["..tag.."] ".. str .. '\n')
end
function log.close() io.close(log.filestream) end
--[[
local page = {
    menubar = {
        buttons = {
            {text="File", event="file"},
            {text="Edit", event="edit"},
        },
    },
    -- Prompt = user input but can be anywhere so give a pos
    readLine = {
        y = -1,    -- Means 1 from the bottom
        shadowText = "Enter message",
        key_events = {
            enter = "message_send",
            up    = "message_edit",
            down  = "message_clear",
            mouse_rightclick = "message_clear"
        },
    }
}]]

-- Create new page
function libgui:newPage(obj, page)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self
  self.page = page
  self.mon = term
  return obj
end
function libgui:setPage(page) self.page = page end
function libgui:setMon(mon) self.mon = mon end

function libgui:clear()
  self.mon.setCursorPos(1,1)
  self.mon.setTextColor(self.themes[self.themes.selectedTheme].textColor)
  self.mon.setBackgroundColor(self.themes[self.themes.selectedTheme].backgroundColor)
  self.mon.clear()
end

-- Render page which user set with libgui:setPage
function libgui:render()
  -- Clear Screen
  libgui:clear()
  self.maxx, self.maxy = self.mon.getSize()

  for k,v in pairs(self.page) do
    if (k=="menubar") then
      self.mon.setCursorPos(1,1)
      self.mon.setBackgroundColor(self.themes[self.themes.selectedTheme][k].backgroundColor)
      self.mon.clearLine()
      -- For each object inside the menubar.
      local horizontaloffset = 1
      for i, button in ipairs(v.button) do
        -- Height of menubar
        button.y = 1
        -- Determine x position
        button.x = horizontaloffset
        horizontaloffset = button.x + button.text:len() + (2*self.padding_horizontal)
      end
      libgui:renderPart("button",v.button)
    end
    -- Start recursively rendering object
    libgui:renderPart(k,v)
  end
end

--[[
  This function is for recursivly rendering objects
  TODO: if (v.visible) then ? (Dont forget to add this to the render part too!)
]]
function libgui:renderPart(key,obj)
  -- obj is a list of key objects!
  for i,v in ipairs(obj) do
    if (not v.textColor) then
      -- if textColor is not set -> Use theme's
      self.mon.setTextColor(self.themes[self.themes.selectedTheme][key].textColor)
    else
      self.mon.setTextColor(v.textColor)
    end
    if (not v.backgroundColor) then
      -- if backgroundColor is not set -> Use theme's
      self.mon.setBackgroundColor(self.themes[self.themes.selectedTheme][key].backgroundColor)
    else
      self.mon.setBackgroundColor(v.backgroundColor)
    end
    -- If it's a standard object -> Determine x pos using global settings
    if (not v.x) then
      v.x = self.padding_horizontal
    elseif (v.x < 0) then
      -- Start from the right of screen
      v.x = self.maxx + v.x - v.text:len()
    end
    if (key=="text") then
      self.mon.setCursorPos(v.x, v.y)
      self.mon.write(v.text)
    elseif (key=="button") then
      self.mon.setCursorPos(v.x, v.y)
      if (v.selected) then
        if (not v.selectedColor) then
          self.mon.setBackgroundColor(self.themes[self.themes.selectedTheme][key].selectedColor)
        else
          self.mon.setBackgroundColor(v.selectedColor)
        end
      end
      self.mon.write(v.text)
    end
  end
end

function libgui:handleEvent(e, obj)
  obj = obj or self.page
  if (e[1]=="key_up" and e[2] == 46) then
    libgui:clear()
    return false
  end
  if (e[1]=="mouse_click") then
    -- e[3] = x, e[4] = y
    -- Find buttons
    for k,v in pairs(obj) do
      if (k=="menubar") then
        -- Recursion because you can have in your menubar buttons and text
        -- -> Pass object v
        libgui:handleEvent(e,v)
      elseif (k=="button") then
        -- Clickable! v is a list of buttons
        for _, kv in ipairs(v) do
          if (kv.y == e[4] and kv.x < e[3] and kv.x+kv.text:len()+(2*self.padding_horizontal) > e[3]) then
            if (kv.onClickEvent ~= nil) then
              -- Execute event when clicked on the button and pass self as argument
              -- TODO: ALSO PASS SELF.PAGE OBJECT so that buttons etc can do something else than switch colors lol
              -- this can be useful to retrieve data or do kernel stuff when pressed
              kv:onClickEvent()--kv.onClickEvent(kv)
            end
          end
        end
      elseif (k=="readLine") then
      end
    end
  end
end

function libgui:main()

end


return libgui
