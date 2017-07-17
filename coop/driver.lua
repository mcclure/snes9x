-- ACTUAL WORK HAPPENS HERE

local spec = {
	running = {addr = 0x7E0010, gte = 0x6}, -- BUT NOT 0x14! Or higher?
	sync = {
		[0x7EF340] = {name="Bow", kind="high"},
		[0x7EF341] = {name="Boomerang", kind="high"},
		[0x7EF342] = {name="Hookshot", kind="high"},
		[0x7EF344] = {nameMap={"Mushroom", "Magic Powder"}, kind="high"},
		[0x7EF345] = {name="Fire Rod", kind="high"},
		[0x7EF346] = {name="Ice Rod", kind="high"},
		[0x7EF347] = {name="Bombos", kind="high"},
		[0x7EF348] = {name="Ether", kind="high"},
		[0x7EF349] = {name="Quake", kind="high"},
		[0x7EF34A] = {name="Lantern", kind="high"},
		[0x7EF34B] = {name="Hammer", kind="high"},
		[0x7EF34C] = {nameMap={"Shovel", "Flute", "Bird"}, kind="high"},
		[0x7EF34D] = {name="Net", kind="high"},
		[0x7EF34E] = {name="Book", kind="high"},
		[0x7EF34F] = {name="Bottle", kind="high"},
		[0x7EF350] = {name="Red Cane", kind="high"},
		[0x7EF351] = {name="Blue Cane", kind="high"},
		[0x7EF352] = {name="Cape", kind="high"},
		[0x7EF353] = {name="Mirror", kind="high"},
		[0x7EF354] = {name="Gloves", kind="high"},
		[0x7EF355] = {name="Boots", kind="high"},
		[0x7EF356] = {name="Flippers", kind="high"},
		[0x7EF357] = {name="Pearl", kind="high"},
		[0x7EF359] = {nameMap={"Fighter's Sword", "Master Sword", "Tempered Sword", "Golden Sword"}, kind="high"},
		[0x7EF35A] = {nameMap={"Shield", "Fire Shield", "Mirror Shield"}, kind="high"},
		[0x7EF35B] = {nameMap={"Blue Armor", "Red Armor"}, kind="high"},
		[0x7EF366] = {name="a Big Key", kind="bitOr"},
		[0x7EF367] = {name="a Big Key", kind="bitOr"},
		[0x7EF379] = {kind="bitOr"}, -- Abilities
		[0x7EF374] = {name="a Pendant", kind="bitOr"},
		[0x7EF37A] = {name="a Crystal", kind="bitOr"},
		[0x7EF37B] = {name="Half Magic", kind="high"}
	}
}

class.GameDriver(Driver)
function GameDriver:_init()
	self.sleepQueue = {}
end

function GameDriver:childTick()
	if #self.sleepQueue > 0 and self:isRunning() then
		local sleepQueue = self.sleepQueue
		self.sleepQueue = {}
		for i, v in ipairs(sleepQueue) do
			self:handleTable(v)
		end
	end
end

function GameDriver:childWake()
	for k,v in pairs(spec.sync) do
		memory.registerwrite (k, 1, function(a,b) self:memoryWrite(a,b,v) end)
	end
end

function GameDriver:isRunning()
	local running = spec.running

	return not running or memory.readbyte(running.addr) >= running.gte
end

function GameDriver:memoryWrite(addr, arg2, record)
	local running = spec.running

	if self:isRunning() then -- TODO: Yes, we got record, but double check
		if not record.cache or record.cache ~= value then -- TODO: Check high/bitOr also?
			print("SILLY DEBUG " .. memory.readbyte(running.addr))
			local value = memory.readbyte(addr)
			record.cache = value -- FIXME: Is this "changed" check redundant?

			self:sendTable({addr=addr, value=value})
		end
	else
		if driverDebug then print("Ignored memory write because the game is not running") end
	end
end

function GameDriver:handleTable(t)
	local addr = t.addr
	local record = spec.sync[addr]
	if self:isRunning() then
		if record then
			local value = t.value
			local allow = true
			local previousValue = memory.readbyte(addr)

			if record.kind == "high" then
				allow = value > previousValue
			elseif record.kind ~= "bitOr" then
				print("SILLY BIT OR DEBUG: Previous value " .. tostring(previousValue) .. " set value " .. tostring(value) .. " final value " .. tostring(OR(value, previousValue)) )
				value = OR(value, previousValue)
				allow = value ~= previousValue
			else
				allow = value ~= previousValue
			end

			if allow then
				local name = record.name

				if not name and record.nameMap then
					name = record.nameMap[value]
				end

				if name then
					message("Partner got " .. name)
				else
					if driverDebug then print("Updated anonymous address " .. tostring(addr) .. " to " .. tostring(value)) end
				end
				record.cache = value
				memory.writebyte(addr, value)
			end
		else
			if driverDebug then print("Unknown memory address was " .. tostring(addr) .. " (" .. type(addr) .. ") record " .. tostring(spec.sync[addr])) end
			message("Partner changed unknown memory address...? Uh oh")
		end
	else
		if driverDebug then print("Queueing partner memory write because the game is not running") end
		table.insert(self.sleepQueue, t)
	end
end

function GameDriver:handleError(s, err)
	print("FAILED TABLE LOAD " .. err)
end
