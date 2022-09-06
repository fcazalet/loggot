class_name LoggotConstants

enum Level {TRACE, DEBUG, INFO, WARN, ERROR}


static func emit_loggot_error(message):
	push_error("LOGGOT ERROR: " + str(message))
