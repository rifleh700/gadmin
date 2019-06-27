
VERSION = "1.0"
LOG_PREFIX = "GADMIN"
DEBUG = true

function enum(args, prefix)
	for i, targ in ipairs(args) do
		if prefix then
			_G[targ] = prefix..i
		else
			_G[targ] = i
		end
	end
end

-- EVENT CALLS
enum(
	{
		"EVENT_SYNC",
		"EVENT_COMMAND",
		"EVENT_SESSION",
		"EVENT_SESSION_UPDATE",
		"EVENT_ACL",
		"EVENT_REPORT",
		"EVENT_PROXY",
		"EVENT_FPS",
		"EVENT_ADMIN_CHAT",
		"EVENT_ADMIN_MENU",
		"EVENT_MESSAGE_BOX",
		"EVENT_SCREEN_SHOT",
		"EVENT_RESOURCE_START",
		"EVENT_RESOURCE_STOP",
		"EVENT_PLAYER_JOIN",
		"EVENT_IP2C",
	},
	"ae"
)

-- SYNC DEFINITIONS
enum(
	{
		"SYNC_PLAYER",
		"SYNC_RESOURCE",
		"SYNC_CHAT",
		"SYNC_SERVER",
		"SYNC_BAN",
		"SYNC_MUTE",
		"SYNC_REPORT",
		"SYNC_SCREENSHOT",
		"SYNC_ACL",
		"SYNC_ADMIN_GROUP",
	},
	"as"
)

-- SYNC TYPE DEFINITIONS
enum(
	{
		"SYNC_LIST",
		"SYNC_SINGLE",
		"SYNC_ADD",
		"SYNC_REMOVE",
		"SYNC_BIGDATA"
	},
	"ast"
)

-- ACL DEFINITIONS
enum(
	{
		"ACL_GROUP",
		"ACL_ACCESS",
		"ACL_ACL",
	},
	"aa"
)

-- PROXY DEFINITIONS
enum(
	{
		"PROXY_ALL",
		"PROXY_BLUR",
		"PROXY_SPECIAL"
	},
	"ap"
)

-- SCREENSHOT DEFINITIONS
enum(
	{
		"SCREENSHOT_SAVE",
		"SCREENSHOT_DELETE"
	},
	"sc"
)

enum(
	{
		"SCREENSHOT_QLOW",
		"SCREENSHOT_QMEDIUM",
		"SCREENSHOT_QHIGH"
	},
	"scq"
)

if not DEBUG then
	function outputDebugString()
		return true
	end
end
