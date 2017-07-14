require "pl.init"
require "ircdialog"

local debug = true

-- UTIL

function nonempty(s) return s and s ~= "" end
function nonzero(s) return s and s ~= 0 end

-- TICKER

local currentError = nil
local currentMessages = List()
local MESSAGE_DURATION = 600

-- Set the current message (optionally, make it an error)
function message(msg, isError)
	if isError then
		currentError = msg
	else
		currentMessages:put({msg, life=MESSAGE_DURATION})
	end
end

-- Callback to print the current error message
function printMessage()
	local msg = null
	if currentError then
		msg = "Error: " .. currentError
	else
		while currentMessages:len() > 0 do
			local messageRecord = currentMessages[#currentMessages]
			if messageRecord.life <= 0 then
				currentMessages:pop()
			else
				msg = messageRecord[1]
				messageRecord.life = messageRecord.life - 1
				break
			end
		end
	end
	if msg then
		gui.text(5, 254-40, msg)
	end
end

-- STATE MACHINES

class.Pipe()
function Pipe:_init()
	self.buffer = ""
end

function Pipe:wake(server)
	if debug then print("Connected") end
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
		error("Connection died: " .. s)
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
				error("Connection died: " .. err)
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

-- TODO: nickserv, reconnect logic

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
					local message = splits2[3]:sub(2)
					
					if self.state == IrcState.piping then       -- Message with payload
						if message:sub(1,1) == "#" then
							self.driver:handle(message:sub(2))
						end
					else                                        -- Handshake message
						local prefix = message:sub(1,2)
						local exclaim = prefix == "!!"
						local confirm = prefix == "@@" 
						if exclaim or confirm then
							if debug then print("Handshake finished") end

							if exclaim then
								self:msg(IrcConfirm)
							end
							self.state = IrcState.piping
							self.driver:wake(self)
						end
					end
				end

			elseif self.state == IrcState.searching and source == self.data.server then
				local splits2 = stringx.split(args, nil, 2)
				local message = tonumber(splits2[1])
				if message and message >= 311 and message <= 317 then -- This is a whois response
					if debug then print("Whois response") end

					self.state = IrcState.handshake
					self:msg(IrcHello)
				end 
			end
		end
	end
end

function IrcPipe:whoisCheck() -- TODO: Check on timer
	self:send("WHOIS " .. self.data.partner)
end

function IrcPipe:msg(s)
	self:send("PRIVMSG " .. self.data.partner .. " :" .. s)
end

class.GameDriver()
function GameDriver:_init()
end

function GameDriver:wake(pipe)
	self.pipe = pipe
end

function GameDriver:handle(s)
	print("DRIVER MESSAGE " .. s)
end

-- PROGRAM

if emu.emulating() then
	local data = ircDialog()
	local failed = false

	function scrub(invalid) message(invalid .. " not valid", true) failed = true end

	if failed then -- NOTHING
	elseif not nonempty(data.server) then scrub("Server")
	elseif not nonzero(data.port) then scrub("Port")
	elseif not nonempty(data.nick) then scrub("Nick")
	elseif not nonempty(data.partner) then scrub("Partner nick")
	end

	function connect()
		local socket = require "socket"
		local server = socket.tcp()
		result, err = server:connect(data.server, data.port)

		if not result then message("Could not connect to IRC: " .. err, true) failed = true return end

		IrcPipe(data, GameDriver()):wake(server)
	end

	if not failed then connect() end

	if failed then gui.register(printMessage) end

	if not failed then
	else
	end
else
	refuseDialog()
end