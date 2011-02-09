
trafikantenHandler =  function (logger) 
	local handler = {}
	handler.log = logger
	
	handler.count = 0	
	handler.stops = {}
	handler.current = ""
	
	handler.starttag = function(self, t, a)
							if (t == "MonitoredStopVisit") then
								io.write("found stop")
								self.count = self.count + 1
								table.insert(handler.stops, {no=self.count })
							end
							handler.current = t
							
							
						end 	
	
   
    handler.endtag = function(self,t,s,e) 
        --io.write("End      : "..t.."\n") 
    end
    handler.text = function(self,t,s,e)
        --io.write(t)
		if handler.current == "DestinationDisplay" then
			self.stops[self.count].destination = t
		end
		
		if handler.current == "ExpectedDepartureTime" then
			self.stops[self.count].departuretime = t
		end
		
		if handler.current == "PublishedLineName" then
			self.stops[self.count].line = t
		end		
    end
	
    handler.cdata = function(self,t,s,e)
       -- io.write("CDATA    : "..t.."\n") 
    end
    handler.comment = function(self,t,s,e)
       -- io.write("Comment  : "..t.."\n") 
    end
    handler.dtd = function(self,t,a,s,e)     
     
    end
    handler.pi = function(self,t,a,s,e) 
        
    end
    handler.decl = function(self,t,a,s,e) 
      
    end
    
	handler.print = function(self)
		local out = ""
		
		for i, v in ipairs(self.stops) do			
			self.log:info("Departuretime: "..v.departuretime)
			local deptime = calculateDeparturetime(v.departuretime, self.log)
			local line = v.line.." "..v.destination.." - "..deptime.."\n"
			out = out..line
			self.log:info(line)
		end
		return out
		
	end
	
	handler.getstops = function(self)
		local stoplist = {}
		for i, v in ipairs(self.stops) do			
			local deptime = calculateDeparturetime(v.departuretime)
			table.insert(stoplist, {line = v.line, destination = v.destination, departure = deptime})
		end
		return stoplist
	end
	return handler
end

function calculateDeparturetime(departuretime, logger)		
	logger:info("deptime: "..departuretime.."\n")
	logger:info("Now: "..os.date().."\n")
	local currdatetab = os.date("*t")
	local estdatetab = DateParse(departuretime)
	local spanminutes = (estdatetab.hour*60 + estdatetab.min) - (currdatetab.hour*60 + currdatetab.min)
	logger:info("Spanminutes: "..spanminutes)
	if spanminutes < 10 then
		if spanminutes <  1 then
			deptime = "nå"
		else
			deptime = math.floor(spanminutes).." min"
		end
	else
		deptime = string.format("%2d:%2d", estdatetab.hour, estdatetab.min)
	end
	return deptime
end

function DateParse(dateval)
	local yearstr, monthstr, daystr, hourstr, minutestr, secondstr, tz, tzhourstr, tzminutestr  = dateval:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)(.)(%d+):(%d+)")
	local date = {}

	date.year = tonumber(yearstr)
	date.month = tonumber(monthstr)
	date.day = tonumber(daystr)
	date.hour = tonumber(hourstr)
	date.min = tonumber(minutestr)
	date.sec = tonumber(secondstr)
	date.tz = tz
	date.tzhour = tonumber(tzhourstr)
	date.tzminute = tonumber(tzminutestr) 

	return date
end

return trafikantenHandler 