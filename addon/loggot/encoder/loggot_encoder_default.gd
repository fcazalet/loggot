extends LoggotEncoder
class_name LoggotEncoderDefault


const MARKER_TIME = "{TIME}"
const MARKER_LEVEL = "{LVL}"
const MARKER_ORIGIN = "{ORGN}"
const MARKER_MESSAGE = "{MSG}"
const DEFAULT_FORMAT = "{TIME} {LVL} {ORGN}: {MSG}"

var format : String


func _init(format = DEFAULT_FORMAT):
	self.format = format


func encode(event : LoggotEvent):
	var msg_with_args = ""
	var splitted_msg = event.message.rsplit("{}", true)
	for i in range(0, len(splitted_msg)):
		if i == len(splitted_msg)-1:
			msg_with_args += splitted_msg[i]
			break
		elif len(event.args) <= i:
			msg_with_args += splitted_msg[i] + "{}"
		else:
			msg_with_args += splitted_msg[i] + str(event.args[i])
	var result = format.replace(MARKER_TIME, str(event.time))
	result = result.replace(MARKER_LEVEL, LoggotConstants.Level.keys()[event.level])
	result = result.replace(MARKER_ORIGIN, str(event.origin))
	result = result.replace(MARKER_MESSAGE, msg_with_args)
	return result
