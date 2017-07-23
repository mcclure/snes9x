class   = require "pl.class"
pretty  = require "pl.pretty"
List    = require "pl.list"
stringx = require "pl.stringx"

require "util"
require "modes.index"
require "dialog"
require "pipe"
require "driver"

-- PROGRAM

if emu.emulating() then
	local spec = nil -- Mode specification
	local specOptions = {}
	for i,v in ipairs(games) do
		if performTest(v.match) then
			table.insert(specOptions, v)
		end
	end

	if #specOptions == 1 then
		spec = specOptions[1]
	elseif #specOptions > 1 then
		spec = selectDialog(specOptions, "multiple matches")
	else
		spec = selectDialog(games, "no matches")
	end

	if spec then
		print("Playing " .. spec.name)

		local data = ircDialog()

		if data then
			local failed = false

			function scrub(invalid) errorMessage(invalid .. " not valid") failed = true end

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

				if not result then errorMessage("Could not connect to IRC: " .. err) failed = true return end

				statusMessage("Connecting to server...")

				mainDriver = GameDriver(spec, data.forceSend) -- Notice: This is a global, specs can use it
				IrcPipe(data, mainDriver):wake(server)
			end

			if not failed then connect() end

			if failed then gui.register(printMessage) end
		end
	end
else
	refuseDialog()
end
