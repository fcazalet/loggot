extends LoggotAppender
class_name LoggotAsyncAppender


var started = false

var mutex : Mutex
var semaphore : Semaphore
var thread : Thread
var exit_thread = false

var queue_size = 256
var events_queue = []

var appender : LoggotAppender


func _init(appender : LoggotAppender):
	self.mutex = Mutex.new()
	self.semaphore = Semaphore.new()
	self.thread = Thread.new()
	self.appender = appender


func do_append(event : LoggotEvent):
	# Prevent re-entry.
	mutex.lock()
	if not started or not appender.is_started():
		return
	events_queue.append(event)
	# TODO improve pop queue
	if len(events_queue) > queue_size:
		events_queue.pop_front()
	mutex.unlock()
	if Engine.is_editor_hint(): # On Editor, synch append
		for event_e in events_queue:
			appender.do_append(event_e)
		events_queue.clear()
		appender.flush()
	else:
		semaphore.post()


func get_name():
	return appender.get_name()


func start():
	appender.start()
	if Engine.is_editor_hint():
		# Do not start thread on Editor, some weird things happens
		pass
	else:
		thread.start(Callable(self, "_thread_append_events"))
	started = true


func stop():
	if not Engine.is_editor_hint():
		# Ask stop to nxt thread run
		mutex.lock()
		exit_thread = true
		mutex.unlock()
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
		semaphore.wait()

		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()

		if should_exit:
			break

		mutex.lock()
		if len(events_queue) == 0:
			mutex.unlock()
			continue
		else:
			var events_to_append = []
			for event in events_queue:
				events_to_append.append(event)
			events_queue.clear()
			mutex.unlock()
			for event in events_to_append:
				appender.do_append(event)
			appender.flush()
