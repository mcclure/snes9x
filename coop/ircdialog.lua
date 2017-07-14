require "iuplua"

function ircdialog()
	local res, server, port, nick, partner = iup.GetParam("Connection settings", nil,
	    "Enter an IRC server: %s\n" ..
		"IRC server port: %i\n" ..
		"Your nick: %s\n" ..
		"Partner nick: %s\n"
	    ,"irc.speedrunslive.com", 6667, "mcc2", "")

	if 0 == res then return nil end

	return {server=server, port=port, nick=nick, partner=partner}
end
