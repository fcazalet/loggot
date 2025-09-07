extends LoggotAppender
class_name LoggotFileAppender

const BUFFER_SIZE = 64

var encoder : LoggotEncoder
var append
var file : FileAccess
var path
var buffer
var buffer_idx = 0
var started = false

func _init(path: String = "loggot.log", encoder : LoggotEncoder = LoggotEncoderDefault.new(), append = false):
	self.encoder = encoder
	self.append = append
	self.path = "user://" + path
	self.buffer = PackedStringArray()
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
	file = FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		LoggotConstants.emit_loggot_error("Could not open the '%s' log file; exited with error %d." % [path, FileAccess.get_open_error()])
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
	if not (path.is_absolute_path() or path.is_rel_path()):
		LoggotConstants.emit_loggot_error("Path3D '%s' is not valid." % path)
		return false
	var base_dir = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(base_dir):
		var err = DirAccess.make_dir_recursive_absolute(base_dir)
		if err:
			LoggotConstants.emit_loggot_error("Could not create %s; exited with error %d." % [base_dir, err])
			return false
	if not FileAccess.file_exists(path) or not append:
		var tmp_file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if tmp_file!= null:
			tmp_file.close()
	return true
