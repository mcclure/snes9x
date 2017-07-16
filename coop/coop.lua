class   = require "pl.class"
pretty  = require "pl.pretty"
List    = require "pl.list"
stringx = require "pl.stringx"

require "util"
require "ircdialog"
require "pipe"
require "driver"

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

else
	refuseDialog()
end
