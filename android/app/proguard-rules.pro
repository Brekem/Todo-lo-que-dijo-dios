# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Firestore
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keepattributes Signature
-keepattributes *Annotation*

# Crashlytics: conserva números de línea para trazas legibles
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Play Core (deferred components de Flutter)
-dontwarn com.google.android.play.core.**
