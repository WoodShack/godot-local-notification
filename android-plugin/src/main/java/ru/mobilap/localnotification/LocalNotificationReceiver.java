package ru.mobilap.localnotification;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.NotificationChannel;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import androidx.core.app.NotificationCompat;

import android.os.Build;
import android.util.Base64;
import android.util.Log;
import android.net.Uri;
import android.media.RingtoneManager;
import org.godotengine.godot.Godot;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

public class LocalNotificationReceiver extends BroadcastReceiver {
    private static final String TAG = "Godot NotificationR";
    public static final String NOTIFICATION_CHANNEL_ID = "10001" ;

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        String[] actionList = action.split(",");

        int notificationId = Integer.parseInt(decode(actionList[0]));
        String message = decode(actionList[1]);
        String title = decode(actionList[2]);
        Log.i(TAG, "Receive notification: "+message);

        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O ) {
            int importance = NotificationManager.IMPORTANCE_HIGH ;
            NotificationChannel notificationChannel = new NotificationChannel( NOTIFICATION_CHANNEL_ID , "Local Notification" , importance) ;
            notificationChannel.setShowBadge(true);
            //builder.setChannelId( NOTIFICATION_CHANNEL_ID ) ;
            manager.createNotificationChannel(notificationChannel) ;
        }

        Class appClass = null;
        try {
            appClass = Class.forName("com.godot.game.GodotApp");
        } catch (ClassNotFoundException e) {
            // app not found, do nothing
            return;
        }
        
        Intent intent2 = new Intent(context, appClass);
        intent2.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT | Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);

        PendingIntent pendingIntent;
        if(android.os.Build.VERSION.SDK_INT  >= Build.VERSION_CODES.M) {
            pendingIntent = PendingIntent.getActivity(context, 0, intent2, PendingIntent.FLAG_IMMUTABLE);
        } else {
            pendingIntent = PendingIntent.getActivity(context, 0, intent2, PendingIntent.FLAG_UPDATE_CURRENT);
        }

        int iconID = context.getResources().getIdentifier("icon", "mipmap", context.getPackageName());
        int notificationIconID = context.getResources().getIdentifier("notification_icon", "mipmap", context.getPackageName());
        Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), iconID);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID);
        int colorID = context.getResources().getIdentifier("notification_color", "color", context.getPackageName());
        builder.setShowWhen(false);
        builder.setContentTitle(title);
        builder.setContentText(message);
        if (notificationIconID <= 0)
            builder.setSmallIcon(iconID);
        else
            builder.setSmallIcon(notificationIconID);
        builder.setLargeIcon(largeIcon);
        builder.setBadgeIconType(NotificationCompat.BADGE_ICON_LARGE);
        builder.setTicker(message);
        builder.setAutoCancel(true);
        builder.setDefaults(Notification.DEFAULT_ALL);
        builder.setColorized(true);
        if (colorID <= 0)
            builder.setColor(Color.RED);
        else
            builder.setColor(context.getResources().getColor(colorID));
        builder.setContentIntent(pendingIntent);
        builder.setNumber(1);
        builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE));
        builder.setPriority(NotificationCompat.PRIORITY_HIGH);

        Notification notification = builder.build();
        notification.sound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);

        manager.notify(notificationId, notification);
    }

    private String decode(String base64){
        try {
            return new String(Base64.decode(base64, Base64.DEFAULT), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return "";
        }
    }
}
