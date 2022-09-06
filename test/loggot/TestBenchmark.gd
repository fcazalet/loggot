extends Control

var logger_test : LoggotLogger

func _ready():
	logger_test = Loggot.get_logger("logger_test")
	logger_test.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))


func _process(delta):
	logger_test.info("Test Log. Delta: {}", [delta])
