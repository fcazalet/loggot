@tool
extends Node
class_name LoggotNode

signal stopped_and_flushed()

const FLUSH_RATE_SEC = 0.5

var loggers = {}
var last_flush_time = 0

func _ready():
	pass


func _process(delta):
	last_flush_time += delta
	if last_flush_time >= FLUSH_RATE_SEC:
		last_flush_time = 0
		flush()


func get_logger(name, appender : LoggotAppender = null) -> LoggotLogger :
	if loggers.has(name):
		return loggers[name]
	else:
		var logger = LoggotLogger.new(LoggotConstants.Level.DEBUG, name)
		if appender != null:
			logger.attach_appender(appender)
		loggers[name] = logger
		return loggers[name]


func flush():
	for name in loggers:
		loggers[name].flush()


func stop_and_flush():
	for name in loggers:
		loggers[name].stop()
	emit_signal("stopped_and_flushed")


func _exit_tree():
	stop_and_flush()
