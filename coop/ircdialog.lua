require "iuplua"

function ircdialog()
	local res, server, port, channel, nick, needKey, key = iup.GetParam("Connection settings", nil,
	    "Enter an IRC server: %s\n" ..
		"IRC server port: %i\n" ..
		"Channel: %s\n" ..
		"Your nick: %s\n" ..
		"Join: %o|Create new game|Enter key|\n" ..
		"Key: %s\n"
	    ,"irc.speedrunslive.com", 6667, "#mcc-test", "mcc2", 0, "")

	if 0 == res then return nil end

	return {server=server, port=port, channel=channel, nick=nick, needKey=needKey~=0, key=key}
end
