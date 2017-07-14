-- ACTUAL WORK HAPPENS HERE

local SyncTypes = {Equal = 1, High = 2}
local syncTable = {
	[0x7EF34A] = {name="Lantern", kind=SyncTypes.High}
}

class.GameDriver(Driver)
function GameDriver:_init()
end

function GameDriver:childWake()
	for k,v in pairs(syncTable) do
		memory.registerwrite (k, 1, function(a,b) self:memoryWrite(a,b,v) end)
	end
end

function GameDriver:memoryWrite(addr, value, record)
	if not record.cache or record.cache ~= value then
		record.cache = value -- FIXME: Is this "changed" check redundant?

		self:sendTable({addr=addr, value=value})
	end
end

function GameDriver:handleTable(t)
	local addr = t.addr
	local record = syncTable[t.addr]
	if record then
		print("TEST REMOVE THIS")
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
