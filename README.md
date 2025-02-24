# Local/Push notification plugin for Godot engine

This is a module for [Godot Game Engine](http://godotengine.org/) which add local and remote notification feature for iOS and Android. 

## Installation Godot 3.5

1. Download the latest release and move the files into your godot project

2. Enable **Custom Build** for using in Android.

3. Set Android Target SDK to 33 or higher in the Android export menu.

4. Add `android.permission.POST_NOTIFICATIONS` and `android.permission.SCHEDULE_EXACT_ALARM` as custom permissions in the Android export menu.

5. Enable Local Notification Plugin in the Android export menu.

## Usage

Add `localnotification.gd` into autoloading list in your project. So you can use it everywhere in your code.

## API

### show(message: String, title: String, interval: float, tag: int, repeating_interval: int = 0)

Show notification with `title` and `message` after delay of `interval` seconds with `tag`. You can override notification by it's tag before it was fired.
If you defined `repeating_interval` the notification will be fired in a loop until you cancelled it.

### show_daily(message: String, title: String, hour: int, minute: int, tag: int = 1)

Show notification daily at specific hour and minute (in 24 hour format).
You can overide the notification with new time, or cancel it with tag and register a new one.

On android the timing is NOT exact.

### cancel(tag: int)

Cancel previously created notification (implemented for iOS only).

### cancelAndroid(message: String, title: String, tag: int)

Cancel previously created notification (implemented for Android only).

### cancel_all()

Cancel all pending notifications (implemented for iOS only).

### init()

Request permission for notifications (iOS and Android 13+).

### is_inited() -> bool

Check if notification permission was requested from user (iOS only).

### is_enabled() -> bool

Check if notification permission was granted by user (iOS only).

### register_remote_notification()

Request system token for push notifications.

### get_device_token() -> String

Returns system token for push notification.

### get_notification_data() -> Dictionary

Returns custom data from activated notification (Android only).

### get_deeplink_action() -> String

Returns action from deeplink, if exists. (Android only).

### get_deeplink_uri() -> String

Returns deeplink URI, if exists (Android only).

## Customising notifications for Android

The default notification color is defined in `android/build/res/values/notification-color.xml`. You can change it at your desire. The color string format is `#RRGGBB`.

In order to change default notification icon you should make this new files:
```
android/build/res/mipmap/notification_icon.png            Size 192x192
android/build/res/mipmap-hdpi-v4/notification_icon.png    Size 72x72
android/build/res/mipmap-mdpi-v4/notification_icon.png    Size 48x48
android/build/res/mipmap-xhdpi-v4/notification_icon.png   Size 96x96
android/build/res/mipmap-xxhdpi-v4/notification_icon.png  Size 144x144
android/build/res/mipmap-xxxhdpi-v4/notification_icon.png Size 192x192
```
Notification icons should be b/w with alpha channel. They will be tinted with color which we discuss above.

## Use push notifications for iOS

1) check if notifications `is_inited`, it means that application requested permissions from user.
2) call `init` if app didn’t requested it yet.
3) catch signal `enabled` or check method `is_enabled`. It will return `false` if user didn’t grant you permission.
4) get device token (`get_device_token`) for push notifications or catch signal `device_token_received`
5) send your device token to the server side.

That’s all. Sending notifications processed by your server, receiving notifications processed by OS. 

## Troubleshooting

If the notification doesn't appear, make sure you're not trying to display it while your game is in the foreground. In iOS, apps can only show notifications if they are in the background. This implies that you must use `interval` > 0.

## iOS Compile

1) [Download](https://github.com/godotengine/godot-cpp/tags) godot-cpp V3.2.3 and put in `/ios-framework/godot-cpp`
2) [Download](https://github.com/godotengine/godot-headers/tags) godot-headers V3.2.3 put in `/ios-framework/godot-cpp/godot-headers`
3) in `/ios-framework/godot-cpp` run `scons platform=ios generate_bindings=yes target=release`
4) in` xcode/Targets/gdnative_ios/General/Frameworks and Libraries` remove `lgodot-cpp.ios.release` and add `/ios-framework/godot-cpp/bin/libgodot-cpp.ios.release.arm64.a`
5) in `/ios-framework/` run `./xcframework_build.sh`