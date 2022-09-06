extends Control


var logger_test : LoggotLogger
var log_counter = 0

func _ready():
	logger_test = Loggot.get_logger("logger_test")
	logger_test.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
	logger_test.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))


func _process(delta):
	log_counter += 2
	logger_test.info("Log messages: {}", [log_counter])
