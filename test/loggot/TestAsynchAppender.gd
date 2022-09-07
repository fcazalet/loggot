extends Control


var logger_test : LoggotLogger


func _ready():
	logger_test = Loggot.get_logger("logger_test")
	logger_test.set_level(LoggotConstants.Level.TRACE)
	logger_test.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))


func _process(delta):
	logger_test.info("======================")
	logger_test.error("Loggot is logging ERROR")
	logger_test.warn("Loggot is logging WARN")
	logger_test.info("Loggot is logging INFO")
	logger_test.debug("Loggot is logging DEBUG")
	logger_test.trace("Loggot is logging TRACE")
