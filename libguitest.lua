package.loaded.libgui = nil
local libgui = require("libgui")
local ui = libgui:newPage()

ui:setPage({
    menubar = {
        button = {
            {
                text="File",
                onClickEvent=function(self)
                end
            },
            {
                text="Edit",
                onClickEvent=function(self)
                    if (not self.selected or self.selected == false) then
                        self.selected = true
                    else
                        self.selected = false
                    end
                end
            },
            {
                text="Clickme",
                onClickEvent=function(self)
                    self.selected = true
                end
            },
            {
                text="Exit",
                type="exit_page",
                clicked = false,
                onClickEvent=function(self)
                    if (self.clicked == false) then
                        self.clicked = true
                        self.backgroundColor = colors.lightGray
                    else
                        self.clicked = false
                        self.backgroundColor = colors.white
                    end
                end
            },
        },
    },
    button = {
        {y = 2, x = 20, text = "Hello", onClickEvent = function(self) self.text="OH COOL!" self.backgroundColor = colors.white end},
    },
    text = {
        {y = 3, x = 3, text="Well hello there :)"},
        {y = 4, x = 4, text="Oh this works?"},
    },
})
ui:render()

while true do
    local e = {os.pullEvent()}
    if (ui:handleEvent(e) == false) then
        break
    end
    ui:render()
end



