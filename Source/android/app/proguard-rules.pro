# ProGuard Rules for stundaa Release Build

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.lifecycle.** { *; }

# Pusher Channels Flutter (Official)
-keep class com.pusher.client.** { *; }
-keep class com.pusher.java_websocket.** { *; }
-keep class com.pusher.channels.flutter.** { *; }

# Gson rules (Gson is used by many packages like flutter_callkit_incoming)
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Prevent obfuscation of platform channels
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
