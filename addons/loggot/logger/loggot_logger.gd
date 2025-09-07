@tool
class_name LoggotLogger

var name
var level : int
var appenders = {}

func _init(level : int, name):
	self.level = level
	self.name = name


func set_level(level : int):
	self.level = level


func attach_appender(appender : LoggotAppender):
	if appender== null or appender.get_name() == null:
		return
	if appenders.has(appender.get_name()):
		if appenders[appender.get_name()].is_started():
			appenders[appender.get_name()].stop()
	appenders[appender.get_name()] = appender
	appender.start()


func detach_appender(name : String):
	if name == null:
		return
	if appenders.has(name):
		if appenders[name].is_started():
			appenders[name].stop()
	appenders.erase(name)


func detach_and_stop_all_appenders():
	for name in appenders:
		detach_appender(name)


func is_attached(name):
	return appenders.has(name)


func get_appender(name):
	if appenders.has(name):
		return appenders[name]
	else:
		return null


func filter_and_log(level , message:String, args:Array):
	# TODO improve filtering
	if level < self.level or ( not OS.is_debug_build() and level < LoggotConstants.Level.INFO):
		return
	build_event_and_append(level, message, args)


func build_event_and_append(level, message:String, args:Array):
	var event = LoggotEvent.new(name, Time.get_ticks_msec(), level, message, args)
	call_appenders(event)


func call_appenders(event : LoggotEvent):
	for name in appenders:
		var appender = appenders[name]
		if appender is LoggotAppender:
			appender.do_append(event)


func trace(message:String, args:Array = []):
	filter_and_log(LoggotConstants.Level.TRACE, message, args)


func debug(message:String, args:Array = []):
	filter_and_log(LoggotConstants.Level.DEBUG, message, args)


func info(message:String, args:Array = []):
	filter_and_log(LoggotConstants.Level.INFO, message, args)


func warn(message:String, args:Array = []):
	filter_and_log(LoggotConstants.Level.WARN, message, args)


func error(message:String, args:Array = []):
	filter_and_log(LoggotConstants.Level.ERROR, message, args)


func flush():
	for name in appenders:
		appenders[name].flush()


func stop():
	for name in appenders:
		appenders[name].stop()
