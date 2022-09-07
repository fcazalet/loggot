extends LoggotAppender
class_name LoggotSignalAppender

signal event_received(event)
signal event_encoded(message)

var encoder : LoggotEncoder

func _init(encoder : LoggotEncoder = LoggotEncoderDefault.new()):
	self.encoder = encoder

func do_append(event : LoggotEvent):
	emit_signal("event_received", event)
	var output = encoder.encode(event)
	if output:
		emit_signal("event_encoded", output)


func get_name():
	return "LoggotConsoleAppender"


func start():
	pass


func stop():
	pass


func is_started():
	return true

