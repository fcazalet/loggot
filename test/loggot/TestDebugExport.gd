extends Control


var logger_test : LoggotLogger
var log_timer = 0


func _ready():
	logger_test = Loggot.get_logger("logger_test")
	logger_test.set_level(LoggotConstants.Level.TRACE)
	logger_test.attach_appender(LoggotConsoleAppender.new())
	var loggot_signal_appender : LoggotSignalAppender = LoggotSignalAppender.new()
	logger_test.attach_appender(loggot_signal_appender)
	loggot_signal_appender.connect("event_encoded", Callable(self, "_on_loggot_message"))


func _on_Timer_timeout():
	logger_test.info("======================")
	logger_test.info("is_debug_build: {}", [OS.is_debug_build()])
	logger_test.error("Loggot is logging ERROR")
	logger_test.warn("Loggot is logging WARN")
	logger_test.info("Loggot is logging INFO")
	logger_test.debug("Loggot is logging DEBUG")
	logger_test.trace("Loggot is logging TRACE")


func _on_loggot_message(message):
	$RichTextLabel.add_text(message)
	$RichTextLabel.add_text("\n")
