 --[[
 =head1 NAME
 
 applets.Doomsday.DoomsdayApplet - Doomsday Applet
 
 =head1 DESCRIPTION
 
 This applet was created solely for the purpose of a demonstration
 
 =head1 FUNCTIONS
 
 Applet related methods are described in L<jive.Applet>. 
 
 =cut
 --]]
 
 
 -- stuff we use
local xmlParser = dofile('lua/applets/Trafikanten/xmlParser.lua')
local trafikantenHandler  	  = dofile('lua/applets/Trafikanten/TrafikantenHandler.lua')

 local tostring = tostring
 local oo                     = require("loop.simple")
 local string                 = require("string")
 local os 					  = require("os")
 local Applet                 = require("jive.Applet")
 local RadioButton            = require("jive.ui.RadioButton")
 local RadioGroup             = require("jive.ui.RadioGroup")
 local Window                 = require("jive.ui.Window")
 local Popup                  = require("jive.ui.Popup")
 local Textarea               = require('jive.ui.Textarea')
 local SimpleMenu             = require("jive.ui.SimpleMenu")
 local Group                  = require("jive.ui.Group")
 local RequestHttp            = require("jive.net.RequestHttp") 
 local SocketHttp             = require("jive.net.SocketHttp") 
 local lfs 					  = require("lfs") 
 local jnt 					  = jnt
 


 
 module(...)
 oo.class(_M, Applet)
 
 function menu(self, menuItem)
 
       log:info("menu")
       local group = RadioGroup()
       local currentSetting = self:getSettings().currentSetting
	   local xml = "";
	   
	   local menu = SimpleMenu("holdeplass", {
			{
				text = "Lørenvangen",
				callback 	= function(event, menuItem)
								log:info("Lørenvangen")						
								local stopid = 3012087
								self:makeRequest(stopid)
								
								
								
							end
			},
			{
				text = "Sinsen Kirke",
				callback 	= function(event, menuItem)
								local stopid = 3011482
								log:info("Sinsen Kirke")
								self:makeRequest(stopid)
								end
			},
			{
				text = "Carl Berner",
				callback 	= function(event, menuItem)
								local stopid = 3011400
								log:info("Carl Berners plass (T)")
								self:makeRequest(stopid)
								end
			},
			{
				text = "Debug",
				callback = function(event, menuItem)
								self:sliderWindow("AppletDir:"..lfs.currentdir())
							end
			}
		})
		
 
       -- create a window object
       local window = Window("window", "Trafikanten") 
 
       -- add the SimpleMenu to the window
       window:addWidget(menu)
 
       -- show the window
       window:show()
 end
 
 function makeRequest(self, stopid)
	self.xml = ""
	local host = "reis.trafikanten.no"
	local port = 80
	local path = "/siri/sm.aspx?id="..stopid																
	local http = SocketHttp(jnt, host, port, "whatsthis")
	local req = RequestHttp(function(chunk, err)
							if chunk then
								log:debug("Http Response")
								self.xml = self.xml .. chunk
								self:parseResponse()
							end
						end, 'GET',	path)
	http:fetch(req)
end

 
 function parseResponse(self)
	log:debug("Parsing response")
	 h = trafikantenHandler(log)
	 x = xmlParser(h)
	 x:parse(self.xml)
	 log:info(h:print())
	 self:sliderWindow(h:print())
 end
 
  
 function sliderWindow(self,  message)
	log:debug("Slider window - message: "..message)
	local window = Window("text_list", "Resultat")
	local help = Textarea("help_text", message)

	window:addWidget(help)
	self:tieAndShowWindow(window)
	return window
end

function _getAppletDir()
	local appletdir = nil
	if lfs.attributes("/usr/share/jive/applets") ~= nil then
		appletdir = "/usr/share/jive/applets/"
	else
		-- find the applet directory
		for dir in package.path:gmatch("([^;]*)%?[^;]*;") do
		        dir = dir .. "applets"
		        local mode = lfs.attributes(dir, "mode")
		        if mode == "directory" then
		                appletdir = dir.."/"
		                break
		        end
		end
	end
	if appletdir then
		log:debug("Applet dir is: "..appletdir)
	else
		log:error("Can't locate lua \"applets\" directory")
	end
	return appletdir
end