
db = {
	connection = dbConnect("sqlite", "admin.db"),
	results = {},
	timers = {},
	threads = {}
}

function db.timeout(handle)
	local c = db.threads[handle]
	dbFree(handle)
	if c then
		coroutine.resume(c)
   	end
end

function db.callback(handle)
	local c = db.threads[handle]
	if c then
		db.results[c] = dbPoll(handle, 0)
	end
	dbFree(handle)

	if not c then return end

	if db.timers[c] and isTimer(db.timers[c]) then
		killTimer(db.timers[c])
	end
	coroutine.resume(c)
end

function db.query(query, ...)
	local c = coroutine.running()
	
	local handle = dbQuery(db.callback, db.connection, query, ...)

	db.threads[handle] = c
	db.timers[c] = setTimer(db.timeout, 1000, 1, handle)

	coroutine.yield()

	db.threads[handle] = nil
	local result = db.results[c]
	db.results[c] = nil

	if not result then return {} end
	return result
end

function db.exec(query, ...)
	dbExec(db.connection, query, ...)
end

function db.last_insert_id()
	local result = db.query("SELECT last_insert_rowid() as id")
	if not (result and result[1]) then return false end
	return result[1].id
end
