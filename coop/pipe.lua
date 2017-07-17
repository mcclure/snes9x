-- NETWORKING

-- A Pipe class is responsible for, somehow or other, connecting to the internet and funnelling data between driver objects on different machines.

class.Pipe()
function Pipe:_init()
	self.buffer = ""
end

function Pipe:wake(server)
	if debug then print("Connected") end
	statusMessage("Logging in to server...") -- This creates an unfortunate implicit contract where the driver needs to statusMessage(nil)
	self.server = server
	self.server:settimeout(0)

	emu.registerexit(function()
		self:exit()
	end)

	self:childWake()

	gui.register(function()
		if not self.dead then self:tick() end
		printMessage()
	end)
end

function Pipe:exit()
	if debug then print("Disconnecting") end
	self.dead = true
	self.server:close()
	self:childExit()
end

function Pipe:fail(err)
	self:exit()
end

function Pipe:send(s)
	if debug then print("SEND: " .. s) end

	local res, err = self.server:send(s .. "\r\n")
	if not res then
		errorMessage("Connection died: " .. s)
		self:exit()
		return false
	end
	return true
end

function Pipe:receivePump()
	while true do -- Loop until no data left
		local result, err = self.server:receive(1) -- Pull one byte
		if not result then
			if err ~= "timeout" then
				errorMessage("Connection died: " .. err)
				self.exit()
			end
			return
		end

		-- Got useful data
		self.buffer = self.buffer .. result
		if result == "\n" then -- Only 
			self:handle(self.buffer)
			self.buffer = ""
		end
	end
end

function Pipe:tick()
	self:receivePump()
	self:childTick()
end

function Pipe:childWake() end
function Pipe:childExit() end
function Pipe:childTick() end
function Pipe:handle() end

-- IRC

-- TODO: nickserv, reconnect logic, multiline messages

local IrcState = {login = 1, searching = 2, handshake = 3, piping = 4}
local IrcHello = "!! Hi, I'm a matchmaking bot for SNES games. This user thinks you're running the same bot and typed in your nick. If you're a human and seeing this, they made a mistake!"
local IrcConfirm = "@@"

class.IrcPipe(Pipe)
function IrcPipe:_init(data, driver)
	self:super()
	self.data = data
	self.driver = driver
	self.state = IrcState.login
end

function IrcPipe:childWake()
	self:send("NICK " .. self.data.nick)
	self:send("USER " .. self.data.nick .."-bot 8 * : " .. self.data.nick .. " (snes bot-- testing)")
end

function IrcPipe:childTick()
	self.driver:tick()
end

function IrcPipe:handle(s)
	if debug then print("RECV: " .. s) end

	splits = stringx.split(s, nil, 2)
	local cmd, args = splits[1], splits[2]

	if cmd == "PING" then -- On "PING :msg" respond with "PONG :msg"
		if debug then print("Handling ping") end

		self:send("PONG " .. args)

	elseif cmd:sub(1,1) == ":" then -- A message from a server or user
		local source = cmd:sub(2)
		if self.state == IrcState.login then
			if source == self.data.nick then -- This is the initial mode set from the server, we are logged in
				if debug then print("Logged in to server") end

				self.state = IrcState.searching
				self:whoisCheck()
			end
		else
			local partnerlen = #self.data.partner

			if source:sub(1,partnerlen) == self.data.partner and source:sub(partnerlen+1, partnerlen+1) == "!" then
				local splits2 = stringx.split(args, nil, 3)
				if splits2[1] == "PRIVMSG" and splits2[2] == self.data.nick and splits2[3]:sub(1,1) == ":" then -- This is a message from the partner nick
					local msg = splits2[3]:sub(2)
					
					if self.state == IrcState.piping then       -- Message with payload
						if msg:sub(1,1) == "#" then
							self.driver:handle(msg:sub(2))
						end
					else                                        -- Handshake message
						local prefix = msg:sub(1,2)
						local exclaim = prefix == "!!"
						local confirm = prefix == "@@" 
						if exclaim or confirm then
							if debug then print("Handshake finished") end
							statusMessage(nil)
							message("Connected to partner")

							if exclaim then
								self:msg(IrcConfirm)
							end
							self.state = IrcState.piping
							self.driver:wake(self)
						elseif msg:sub(1,1) == "#" then
							errorMessage("Tried to connect, but your partner is already playing the game! Try resetting?")
						else
							errorMessage("Your partner's emulator responded in... English? You probably typed the wrong nick!")
						end
					end
				end

			elseif self.state == IrcState.searching and source == self.data.server then
				local splits2 = stringx.split(args, nil, 2)
				local msg = tonumber(splits2[1])
				if msg and msg >= 311 and msg <= 317 then -- This is a whois response
					if debug then print("Whois response") end

					statusMessage("Connecting to partner...")
					self.state = IrcState.handshake
					self:msg(IrcHello)
				end 
			end
		end
	end
end

function IrcPipe:whoisCheck() -- TODO: Check on timer
	self:send("WHOIS " .. self.data.partner)
	statusMessage("Searching for partner...")
end

function IrcPipe:msg(s)
	self:send("PRIVMSG " .. self.data.partner .. " :" .. s)
end

-- Driver base class-- knows how to convert to/from tables

driverDebug = true

class.Driver()
function Driver:_init() end

function Driver:wake(pipe)
	self.pipe = pipe
	self:childWake()
end

function Driver:sendTable(t)
	local s = pretty.write(t, '')
	self.pipe:msg("#" .. s)
end

function Driver:handle(s)
	local t, err = pretty.read(s)
	if driverDebug then print("Driver got table " .. tostring(t)) end
	if t then
		self:handleTable(t)
	else
		self.handleFailure(s, err)
	end
end

function Driver:tick()
	self:childTick()
end

function Driver:childWake() end
function Driver:childTick() end
function Driver:handleTable(t) end
function Driver:handleFailure(s, err) end
