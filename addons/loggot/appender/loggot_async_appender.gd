extends LoggotAppender
class_name LoggotAsyncAppender


var started = false

var guard : Mutex
var semaphore : Semaphore
var thread : Thread
var exit_thread = false

var queue_size = 256
var events_queue = []

var appender : LoggotAppender


func _init(appender : LoggotAppender):
	self.guard = Mutex.new()
	self.semaphore = Semaphore.new()
	self.thread = Thread.new()
	self.appender = appender


func do_append(event : LoggotEvent):
	# Prevent re-entry.
	guard.lock()
	if not started or not appender.is_started():
		return
	events_queue.append(event)
	# TODO improve pop queue
	if len(events_queue) > queue_size:
		events_queue.pop_front()
	guard.unlock()
	if Engine.editor_hint: # On Editor, synch append
		for event in events_queue:
			appender.do_append(event)
		events_queue.clear()
		appender.flush()
	else:
		semaphore.post()


func get_name():
	return appender.get_name()


func start():
	appender.start()
	if Engine.editor_hint:
		# Do not start thread on Editor, some weird things happens
		pass
	else:
		thread.start(self, "_thread_append_events")
	started = true


func stop():
	if not Engine.editor_hint:
		# Ask stop to nxt thread run
		guard.lock()
		exit_thread = true
		guard.unlock()
		# authorize a thread run
		semaphore.post()
		# Wait until it exits.
		thread.wait_to_finish()
	appender.stop()
	started = false


func is_started():
	return started


func flush():
	semaphore.post()


func _thread_append_events():
	while true:
		var result = semaphore.wait()

		guard.lock()
		var should_exit = exit_thread
		guard.unlock()

		if should_exit:
			break

		guard.lock()
		if len(events_queue) == 0:
			guard.unlock()
			continue
		else:
			var events_to_append = []
			for event in events_queue:
				events_to_append.append(event)
			events_queue.clear()
			guard.unlock()
			for event in events_to_append:
				appender.do_append(event)
			appender.flush()
