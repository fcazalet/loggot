tool
extends Node
class_name LoggotNode

signal stopped_and_flushed()
var loggers = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_logger(name, appender : LoggotAppender = null) -> LoggotLogger :
	if loggers.has(name):
		return loggers[name]
	else:
		var logger = LoggotLogger.new(LoggotConstants.Level.DEBUG, name)
		if appender != null:
			logger.attach_appender(appender)
		loggers[name] = logger
		return loggers[name]


func stop_and_flush():
	for name in loggers:
		loggers[name].stop()
	emit_signal("stopped_and_flushed")


func _process(delta):
	for name in loggers:
		loggers[name]._tick(delta)


func _exit_tree():
	stop_and_flush()
