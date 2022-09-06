class_name LoggotAppender


var name


func get_name():
	return self.name


func set_name(name):
	self.name = name


func do_append(event : LoggotEvent):
	LoggotConstants.emit_loggot_error("LoggotAppender do_append() method should be overriden")


func flush():
	pass

func start():
	LoggotConstants.emit_loggot_error("LoggotAppender start() method should be overriden")


func stop():
	LoggotConstants.emit_loggot_error("LoggotAppender stop() method should be overriden")


func is_started():
	LoggotConstants.emit_loggot_error("LoggotAppender is_started() method should be overriden")


func _tick(delta):
	pass # Only used by Async appenders to prevent using all memory
