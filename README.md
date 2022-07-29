# Loggot

<img src="https://raw.githubusercontent.com/fcazalet/loggot/master/icon.png" width="64" height="64">

Loggot is a Godot add-on that allow total control on logs.

It allow you to create different named loggers.

For example you can have a logger for a Player node and another for all Enemy nodes and make each log to two separate files player.log and enemy.log.

Or you can log Player output to console and Enemy output to a file. As you want.

Each Logger can have multiple Appender. They also can share same appenders (ex output to same file).

Appender have an Encoder to encode log event to whatever. Basically an Encoder can just output formatted text.

You can wrap an Appender into an AsyncAppender and transform it to an asynchronous Appender.  

You can create your own Appender/Encoder and inject it to Logger/Appender. Just extends it.


## Context

If you run this in GDScript:

	for i in range(0,50):
		print(OS.get_ticks_msec(), " ; print ", i)

It output something like this:

	491 ; print 0
	492 ; print 1
	492 ; print 2
	...
	522 ; print 47
	522 ; print 48
	523 ; print 49

That mean that with 50 prints you lose 32ms (= 2 frames at 60 FPS) in your main process.

If you run it with Loggot and an asynchronous appender:

	var logger = Loggot.get_logger("LoggotLogger")
	logger.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
	for i in range(0,50):
		logger.info("{} ; print {}", [OS.get_ticks_msec(), i])

It output something like this:

	495	INFO	LoggotLogger	495 ; print 0
	495	INFO	LoggotLogger	495 ; print 1
	495	INFO	LoggotLogger	495 ; print 2
	...
	496	INFO	LoggotLogger	496 ; print 47
	496	INFO	LoggotLogger	496 ; print 48
	496	INFO	LoggotLogger	496 ; print 49

You lost only 1ms on the main process, it seems fair enough.

Log are not displayed exactly when asked in the code but it keep the order and all logs are time-logged.
If logs appear some milliseconds after the info() call it should be unnoticeable for human.

## How to install it

You can find this addon in Godot AssetLibrary
See the Godot Addon install section : https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html

## How to use it

In Godot project settings, add an autoload named 'Loggot' that target loggot.gd.

Basic synchronous example:

	var logger = Loggot.get_logger("MyLogger")
	logger.attach_appender(LoggotConsoleAppender.new())
	logger.info("Hello World!")

Output Console:

	524	INFO	MyLogger	Hello World!

Details: 524 is time in msec since game started (I think we do not need a date for gamedev?), INFO as log event level, MyLogger as log origin, and the message.

See "Ouput format" section for more details on formatting.

Each time you call "Loggot.get_logger("MyLogger")" it will return the same logger linked to "MyLogger" name. If it does not exists it create it.

With two sync loggers with the same appender:

	var loggerA = Loggot.get_logger("MyLoggerA")
	var loggerB = Loggot.get_logger("MyLoggerB")
	var appender = LoggotConsoleAppender.new()
	loggerA.attach_appender(appender)
	loggerB.attach_appender(appender)
	loggerA.info("Hello World A!")
	loggerB.debug("Hello World B!")

Output:

	497	INFO	MyLoggerA	Hello World A!
	499	DEBUG	MyLoggerB	Hello World B!

You can use log levels to filter Logger output:

	var loggerA = Loggot.get_logger("MyLoggerA")
	loggerA.attach_appender(LoggotConsoleAppender.new())
	loggerA.set_level(LoggotConstants.Level.INFO)
	loggerA.trace("You can't see this")
	loggerA.debug("You can't see this")
	loggerA.info("You can see this")
	loggerA.warn("You can see this")
	loggerA.error("You can see this")
	# Change level
	loggerA.set_level(LoggotConstants.Level.ERROR)
	loggerA.trace("You can't see this")
	loggerA.debug("You can't see this")
	loggerA.info("You can't see this")
	loggerA.warn("You can't see this")
	loggerA.error("You can see this")

Output:

	570	INFO	MyLoggerA	You can see this
	571	WARN	MyLoggerA	You can see this
	573	ERROR	MyLoggerA	You can see this
	574	ERROR	MyLoggerA	You can see this

You can pass arguments to messages:

	var logger = Loggot.get_logger("MyLogger")
	logger.attach_appender(LoggotConsoleAppender.new())
	logger.info("Loggot is {} and {} like {}", ["fun", "cool", 42.00])
	logger.info("Loggot is {} and {} like {}", [randi(), randf(), "no one"])

Output:

	522	INFO	MyLogger	Loggot is fun and cool like 42
	524	INFO	MyLogger	Loggot is 3161026589 and 0.621225 like no one
	
Asynchronous Logger example:

	var logger = Loggot.get_logger("MyLoggerAsync")
	logger.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
	logger.set_level(LoggotConstants.Level.INFO)
	logger.info("I'am an async appender")
	logger.info("And I can log events")
	logger.info("Without milliseconds")
	logger.info("loss :)")

Output Console:

	493	INFO	MyLoggerAsync	I'am an async appender
	493	INFO	MyLoggerAsync	And I can log events
	493	INFO	MyLoggerAsync	Without milliseconds
	493	INFO	MyLoggerAsync	loss :)


You can use the LoggotFileAppender to output to a file:

	var logger = Loggot.get_logger("MyLoggerAsync")
	logger.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new("loggot_is_hot.log")))
	logger.set_level(LoggotConstants.Level.INFO)
	logger.info("I'am an async file appender")
	logger.info("And I can log events in files")
	logger.info("Without milliseconds")
	logger.info("loss again \\o/")

Output in user://loggot_is_hot.log:

	525	INFO	MyLoggerAsync	I'am an async file appender
	525	INFO	MyLoggerAsync	And I can log events in files
	525	INFO	MyLoggerAsync	Without milliseconds
	525	INFO	MyLoggerAsync	loss again \o/


## Ouput format

The default encoder is LoggotEncoderDefault. You can create you own and inject it into an Appender.

It output log events to this format:

	const DEFAULT_FORMAT = "{TIME}\t{LVL}\t{ORGN}\t{MSG}"


## Force stop and flush

If you want to stop and flush all Loggot loggers and appender, call the Loggot node function 'stop_and_flush()' and survey the 'stopped_and_flushed' signal.

Example to manage hard shutdown:

	func _notification(notification_signal):
		if notification_signal == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			Loggot.stop_and_flush()
			yield(Loggot, 'stopped_and_flushed')
			get_tree().quit()


## Support Me

You to buy me a coffee ?
<a href='https://ko-fi.com/J3J2COV54' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee' /></a>
