class_name LoggotEvent

var origin
var time
var level
var message:String
var args:Array

func _init(origin, time, level, message:String, args:Array):
	self.origin = origin
	self.time = time
	self.level = level
	self.message = message
	self.args = args


