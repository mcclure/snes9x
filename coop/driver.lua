-- ACTUAL WORK HAPPENS HERE

class.GameDriver()
function GameDriver:_init()
end

function GameDriver:wake(pipe)
	self.pipe = pipe
end

function GameDriver:handle(s)
	print("DRIVER MESSAGE " .. s)
end
