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
	if guard.try_lock() == ERR_BUSY:
		return
	if not started or not appender.is_started():
		return
	events_queue.append(event)
	# TODO improve pop queue
	if len(events_queue) > queue_size:
		events_queue.pop_front()
	guard.unlock()
	semaphore.post()


func get_name():
	return appender.get_name()


func start():
	appender.start()
	thread.start(self, "_thread_append_events")
	started = true


func stop():
	# Ask stop to nxt thread run
	guard.lock()
	exit_thread = true
	guard.unlock()
	# authorize a thread run
	semaphore.post()
	# Wait until it exits.
	thread.wait_to_finish()
	started = false


func is_started():
	return started


func _tick(delta):
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
