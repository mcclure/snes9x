-- ACTUAL WORK HAPPENS HERE

local SyncType = {Equal = 1, High = 2}
local spec = {
	running = {addr = 0x7E0010, gte = 0x6},
	sync = {
		[0x7EF34A] = {name="Lantern", kind=SyncType.High}
	}
}

class.GameDriver(Driver)
function GameDriver:_init()
end

function GameDriver:childWake()
	for k,v in pairs(spec.sync) do
		memory.registerwrite (k, 1, function(a,b) self:memoryWrite(a,b,v) end)
	end
end

function GameDriver:memoryWrite(addr, value, record)
	local running = spec.running

	if not running or memory.readbyte(running.addr) >= running.gte then
		if not record.cache or record.cache ~= value then
			record.cache = value -- FIXME: Is this "changed" check redundant?

			self:sendTable({addr=addr, value=value})
		end
	else
		if driverDebug then print("Ignored memory write because the game is not running") end
	end
end

function GameDriver:handleTable(t)
	local addr = t.addr
	local record = spec.sync[t.addr]
	if record then -- TODO honor SyncType
		local value = t.value
		message("Partner got " .. record.name)
		record.cache = value
		memory.writebyte(addr, value)
	else
		message("Partner changed unknown memory address...? Maybe something's broken.")
	end
end

function GameDriver:handleError(s, err)
	print("FAILED TABLE LOAD " .. err)
end
