-- ACTUAL WORK HAPPENS HERE

function recordChanged(record, value, previousValue)
	local allow = true
	print({"TESTING WITH", record=record})

	if type(record.kind) == "function" then
		allow, value = record(value, previousValue)
	elseif record.kind == "high" then
		allow = value > previousValue
	elseif record.kind == "bitOr" then
		local maskedValue         = value                        -- Backup value and previousValue
		local maskedPreviousValue = previousValue

		print({"Inside recordChanged", value=value, previousValue=previousValue, maskedValue=maskedValue, maskedPreviousValue=maskedPreviousValue, record=record})

		if record.mask then                                      -- If necessary, mask both before checking
			maskedValue = AND(maskedValue, record.mask)
			maskedPreviousValue = AND(maskedPreviousValue, record.mask)
		end

		maskedValue = OR(maskedValue, maskedPreviousValue)

		allow = maskedValue ~= maskedPreviousValue               -- Did operated-on bits change?
		value = OR(previousValue, maskedValue)                   -- Copy operated-on bits back into value
		print({"Inside recordChanged2", value=value, previousValue=previousValue, maskedValue=maskedValue, maskedPreviousValue=maskedPreviousValue, allow=allow})
	else
		allow = value ~= previousValue
	end
	if allow and record.cond then
		allow = performTest(record.cond, value)
	end
	return allow, value
end

function performTest(record, valueOverride)
	if not record then return true end

	if record[1] == "test" then
		local value = valueOverride or memory.readbyte(record.addr)
		return (not record.gte or value >= record.gte) and
			   (not record.lte or value <= record.lte)
	elseif record[1] == "stringtest" then
		local test = record.value
		local len = #test
		local addr = record.addr

		for i=1,len do
			if string.byte(test, i) ~= memory.readbyte(addr + i) then
				return false
			end
		end
		return true
	else
		return false
	end
end

class.GameDriver(Driver)
function GameDriver:_init(spec)
	self.spec = spec
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
	for k,v in pairs(self.spec.sync) do
		memory.registerwrite (k, 1, function(a,b) if a==k then self:memoryWrite(a,b,v) end end)
	end
end

function GameDriver:isRunning()
	return performTest(self.spec.running)
end

function GameDriver:memoryWrite(addr, arg2, record)
	local running = self.spec.running

	if self:isRunning() then -- TODO: Yes, we got record, but double check
		local allow = true
		local value = memory.readbyte(addr)

		if record.cache then
			allow = recordChanged(record, value, record.cache)
		end

		if allow then
			record.cache = value -- FIXME: Should this cache EVER be cleared? What about when a new game starts?

			self:sendTable({addr=addr, value=value})
		end
	else
		if driverDebug then print("Ignored memory write because the game is not running") end
	end
end

function GameDriver:handleTable(t)
	local addr = t.addr
	local record = self.spec.sync[addr]
	if self:isRunning() then
		if record then
			local value = t.value
			local allow = true
			local previousValue = memory.readbyte(addr)

			allow, value = recordChanged(record, value, previousValue)

			if allow then
				local name = record.name
				local names = nil

				if not name and record.nameMap then
					name = record.nameMap[value]
				end

				if name then
					names = {name}
				elseif record.nameBitmap then
					names = {}
					for b=0,7 do
						if 0 ~= AND(BIT(b), value) and 0 == AND(BIT(b), previousValue) then
							table.insert(names, record.nameBitmap[b + 1])
						end
					end
				end

				if names then
					for i, v in ipairs(names) do
						message("Partner got " .. name)
					end
				else
					if driverDebug then print("Updated anonymous address " .. tostring(addr) .. " to " .. tostring(value)) end
				end
				record.cache = value
				memory.writebyte(addr, value)
			end
		else
			if driverDebug then print("Unknown memory address was " .. tostring(addr)) end
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
