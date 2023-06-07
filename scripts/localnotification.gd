extends Node

signal device_token_received(token)
signal enabled
var _ln = null

onready var _analytics := $'/root/analytics' if has_node('/root/analytics') else null

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	if Engine.has_singleton("LocalNotification"):
		_ln = Engine.get_singleton("LocalNotification")
	elif OS.get_name() == 'iOS':
		_ln = load("res://addons/localnotification-ios/localnotification.gdns").new()
		_ln.connect('notifications_enabled', self, '_on_notifications_enabled')
		_ln.connect('device_token_received', self, '_on_device_token_received')
	elif OS.get_name() == 'HTML5':
		_ln = load("res://addons/localnotification-html5/HTML5NotificationsPlugin.gd").new()
	if _ln == null:
		push_warning('LocalNotification plugin not found!')
	else:
		print('LocalNotification plugin inited')

func init() -> void:
	if _ln != null:
		_ln.init()
		if OS.get_name() == 'Android':
			androidPermission()

func androidPermission():
	_ln.requestPermission()

func show(message: String, title: String, interval: int, tag: int = 1, repeat_duration: int = 0) -> void:
	if _ln != null:
		if repeat_duration <= 0:
			_ln.showLocalNotification(message, title, interval, tag)
		else:
			_ln.showRepeatingNotification(message, title, interval, tag, repeat_duration)

func show_daily(message: String, title: String, hour: int, minute: int, tag: int = 1) -> void:
	if _ln != null:
		if OS.get_name() == 'Android':
			var past = false;
			
			if(hour < _get_time_hour()):
				past = true
			
			if(hour == _get_time_hour() and minute < _get_time_min()):
				past = true
				
			var hourDif = _number_dif(hour,_get_time_hour())*3600
			var minDif = _number_dif(minute,_get_time_min())*60
			var delay = 0
			
			if(past):
				#Past
				delay = 86400-(hourDif+minDif)
			elif(hour == _get_time_hour() and minute == _get_time_min()):
				#Present
				delay = 86400
			else:
				#Future
				delay = hourDif+minDif
			
			_ln.showRepeatingNotification(message, title, delay, tag, 86400)
		else:
			_ln.showRepeatingNotification(message, title, hour, minute, tag)

func cancel(tag: int = 1) -> void:
	if OS.get_name() == 'Android':
		printerr("Use cancelAndroid instead")
		return
		
	if _ln != null:
		_ln.cancelLocalNotification(tag)
		
func cancelAndroid(message: String, title: String, tag: int = 1) -> void:
	if OS.get_name() != 'Android':
		return
	
	if _ln != null:
		_ln.cancelLocalNotification(message,title,tag)

func cancel_all() -> void:
	if _ln != null:
		_ln.cancelAllNotifications()

func is_inited() -> bool:
	if _ln != null:
		return _ln.isInited()
	else:
		return false

func is_enabled() -> bool:
	if _ln != null:
		return _ln.isEnabled()
	else:
		return false

func register_remote_notification() -> void:
	if _ln != null:
		_ln.register_remote_notification()

func get_device_token():
	if _ln != null:
		return _ln.get_device_token()
	else:
		return null

func get_notification_data():
	if _ln != null:
		return _ln.get_notification_data()
	else:
		return null

func get_deeplink_action():
	if _ln != null:
		return _ln.get_deeplink_action()
	else:
		return null

func get_deeplink_uri():
	if _ln != null:
		return _ln.get_deeplink_uri()
	else:
		return null

func _on_notifications_enabled() -> void:
	if _analytics != null:
		_analytics.event('notifications_enabled')
	emit_signal('enabled')

func _on_device_token_received(token) -> void:
	#print('on_device_token_received: %s'%var2str(token))
	emit_signal('device_token_received', token)

func _get_time_hour():
	return int(Time.get_time_dict_from_system()["hour"])

func _get_time_min():
	return int(Time.get_time_dict_from_system()["minute"])
	
func _number_dif(num1,num2):
	if(num1 < num2):
		return num2-num1
	
	if(num1 > num2):
		return num1-num2
	
	return 0
