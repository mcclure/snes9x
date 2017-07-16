-- ACTUAL WORK HAPPENS HERE

local spec = {
	running = {addr = 0x7E0010, gte = 0x6},
	sync = {
		[0x7EF340] = {name="Bow", kind="high"},
		[0x7EF341] = {name="Boomerang", kind="high"},
		[0x7EF342] = {name="Hookshot", kind="high"},
		[0x7EF344] = {name="Mushroom or Powder", kind="high"},
		[0x7EF345] = {name="Fire Rod", kind="high"},
		[0x7EF346] = {name="Ice Rod", kind="high"},
		[0x7EF347] = {name="Bombos", kind="high"},
		[0x7EF348] = {name="Ether", kind="high"},
		[0x7EF349] = {name="Quake", kind="high"},
		[0x7EF34A] = {name="Lantern", kind="high"},
		[0x7EF34B] = {name="Hammer", kind="high"},
		[0x7EF34C] = {name="Shovel, Flute or Bird", kind="high"},
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
		[0x7EF359] = {name="better Sword", kind="high"},
		[0x7EF35A] = {name="better Shield", kind="high"},
		[0x7EF35B] = {name="better Armor", kind="high"},
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

function GameDriver:memoryWrite(addr, value, record)
	local running = spec.running

	if self:isRunning() then
		if not record.cache or record.cache ~= value then -- TODO: Check high/bitOr also?
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
	if record and self:isRunning() then
		local value = t.value
		local allow = true
		local currentValue = memory.readbyte(addr)

		if record.kind == "high" then
			allow = value > currentValue
		elseif record.kind ~= "bitOr" then
			allow = value == currentValue
			value = OR(value, currentValue)
		else
			allow = value ~= currentValue
		end

		if allow then
			if record.name then
				message("Partner got " .. record.name)
			end
			record.cache = value
			memory.writebyte(addr, value)
		end
	else
		message("Partner changed unknown memory address...? Maybe something's broken.")
	end
end

function GameDriver:handleError(s, err)
	print("FAILED TABLE LOAD " .. err)
end
