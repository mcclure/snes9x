require "pl/init"
require "socket"
require "ircdialog"

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

message("OK")
message("YES")
message("DONE")

gui.register(printMessage)
