extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var loggerA = Loggot.get_logger("MyLoggerA")
	var loggerB = Loggot.get_logger("MyLoggerB")
	var appender = LoggotConsoleAppender.new()
	loggerA.attach_appender(appender)
	loggerB.attach_appender(appender)
	loggerA.info("Hello World A!")
	loggerB.debug("Hello World B!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
