extends LoggotAppender
class_name LoggotConsoleAppender


var encoder : LoggotEncoder

func _init(encoder : LoggotEncoder = LoggotEncoderDefault.new()):
	self.encoder = encoder

func do_append(event : LoggotEvent):
	var output = encoder.encode(event)
	if output:
		print(output)


func get_name():
	return "LoggotConsoleAppender"


func start():
	pass


func stop():
	pass


func is_started():
	return true

