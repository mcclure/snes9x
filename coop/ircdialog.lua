require "iuplua"

function ircDialog()
	local res, server, port, nick, partner = iup.GetParam("Connection settings", nil,
	    "Enter an IRC server: %s\n" ..
		"IRC server port: %i\n" ..
		"Your nick: %s\n" ..
		"Partner nick: %s\n"
	    ,"irc.speedrunslive.com", 6667, "", "")

	if 0 == res then return nil end

	return {server=server, port=port, nick=nick, partner=partner}
end

function refuseDialog()
	iup.Message("Cannot run", "No ROM is running.")
end
