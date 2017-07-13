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
				error("Connection died: " .. s)
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

class.IrcPipe(Pipe)
function IrcPipe:_init(data)
	self:super()
	self.data = data
end

function IrcPipe:childWake()
	self:send("NICK " .. self.data.nick)
	self:send("USER " .. self.data.nick .."-bot 8 * : " .. self.data.nick .. " (snes bot-- testing)")
end

function IrcPipe:handle(s)
	if debug then print("RECV: " .. s) end

	splits = stringx.split(s, nil, 2)
	local cmd, args = splits[1], splits[2]
	if debug and cmd then print("CMD" .. cmd) end

	if cmd == "PING" then
		if debug then print("Handling ping") end

		self:send("PONG " .. args)
	end
end

class.PumpMachine()

-- PROGRAM

local data = ircdialog()
local failed = false

--print(pretty.write(data,''))
--gui.text(0, 0, pretty.write(data,''))

function scrub(invalid) message(invalid .. " not valid", true) falied = true end

if failed then -- NOTHING
elseif not nonempty(data.server) then scrub("Server")
elseif not nonzero(data.port) then scrub("Port")
elseif not nonempty(data.nick) then scrub("Nick")
elseif not nonempty(data.channel) then scrub("channel")
elseif data.needkey and not nonempty(data.key) then scrub("Key")
end

function connect()
	local socket = require "socket"
	local server = socket.tcp()
	result, err = server:connect(data.server, data.port)

	if not result then message("Could not connect to IRC: " .. err, true) failed = true return end

	IrcPipe(data):wake(server)
end

if not failed then connect() end

if failed then gui.register(printMessage) end

if not failed then
else
end