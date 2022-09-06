extends LoggotAppender
class_name LoggotFileAppender

const BUFFER_SIZE = 64

var encoder : LoggotEncoder
var append
var file : File
var path
var buffer
var buffer_idx = 0
var started = false

func _init(path: String = "loggot.log", encoder : LoggotEncoder = LoggotEncoderDefault.new(), append = false):
	self.encoder = encoder
	self.append = append
	self.path = "user://" + path
	self.file = File.new()
	self.buffer = PoolStringArray()
	self.buffer.resize(BUFFER_SIZE)


func do_append(event : LoggotEvent):
	var output = encoder.encode(event)
	if started and output:
		file.store_line(output)


func flush():
	file.flush()


func get_name():
	return "LoggotFileAppender"


func start():
	if init_path(path):
		self.path = path
	# Open File
	var err = file.open(path, File.READ_WRITE)
	if err:
		LoggotConstants.emit_loggot_error("Could not open the '%s' log file; exited with error %d." % [path, err])
		started = false
	file.seek_end()
	started = true


func stop():
	if started:
		# Close File
		file.close()
	started = false


func is_started():
	return started


func init_path(path):
	if not (path.is_abs_path() or path.is_rel_path()):
		LoggotConstants.emit_loggot_error("Path '%s' is not valid." % path)
		return false
	var dir = Directory.new()
	var base_dir = path.get_base_dir()
	if not dir.dir_exists(base_dir):
		var err = dir.make_dir_recursive(base_dir)
		if err:
			LoggotConstants.emit_loggot_error("Could not create %s; exited with error %d." % [base_dir, err])
			return false
	if not file.file_exists(path) or not append:
		var err = file.open(path, File.WRITE)
		file.close()
	return true
