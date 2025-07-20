# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# ========================================
# FLUTTER RECOMMENDED PROGUARD RULES
# ========================================

# Keep all Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter engine and embedding classes
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep Flutter plugin registry and platform channels
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Keep Flutter method channel implementations
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }

# Keep Flutter platform view factories
-keep class * implements io.flutter.plugin.platform.PlatformViewFactory { *; }
-keep class * implements io.flutter.plugin.platform.PlatformView { *; }

# ========================================
# KEEP ALL TAP SDK CLASSES
# ========================================

# Keep ALL Tap Checkout SDK classes - no obfuscation at all
-keep class company.tap.tapcheckout_android.** { *; }
-keep interface company.tap.tapcheckout_android.** { *; }
-keepnames class company.tap.tapcheckout_android.** { *; }
-keepclassmembers class company.tap.tapcheckout_android.** { *; }

# Keep all inner classes, companion objects, and nested classes
-keep class company.tap.tapcheckout_android.**$* { *; }
-keep class company.tap.tapcheckout_android.**$Companion { *; }
-keep class company.tap.tapcheckout_android.**$** { *; }

# Keep all methods, fields, and constructors for Tap SDK
-keepclassmembers class company.tap.tapcheckout_android.** {
    public <init>(...);
    public <methods>;
    private <methods>;
    protected <methods>;
    <fields>;
}

# ========================================
# KEEP ALL FLUTTER PLUGIN CLASSES
# ========================================

# Keep ALL Flutter plugin classes - no obfuscation at all
-keep class com.example.checkout_flutter.** { *; }
-keep interface com.example.checkout_flutter.** { *; }
-keepnames class com.example.checkout_flutter.** { *; }
-keepclassmembers class com.example.checkout_flutter.** { *; }

# Keep all inner classes and companion objects for plugin
-keep class com.example.checkout_flutter.**$* { *; }
-keep class com.example.checkout_flutter.**$Companion { *; }

# Keep all methods, fields, and constructors for plugin
-keepclassmembers class com.example.checkout_flutter.** {
    public <init>(...);
    public <methods>;
    private <methods>;
    protected <methods>;
    <fields>;
}

# ========================================
# KOTLIN SPECIFIC RULES
# ========================================

# Keep all Kotlin metadata to prevent reflection issues
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.** { *; }

# Keep Kotlin coroutines completely
-keep class kotlinx.coroutines.** { *; }
-keepnames class kotlinx.coroutines.** { *; }
-keepclassmembers class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Keep all companion objects and singletons
-keepnames class * {
    public static ** Companion;
    public static ** INSTANCE;
}

# Keep Kotlin data classes and their properties
-keepclassmembers class * {
    @kotlin.jvm.JvmField <fields>;
    public ** component*();
    public ** copy(...);
    public ** copy$default(...);
}

# ========================================
# SERIALIZATION AND JSON
# ========================================

# Keep Gson classes
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

# Keep serialization annotations
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
}

# Keep all fields for data classes to prevent ClassCastException
-keepclassmembers class * {
    <fields>;
}

# ========================================
# NETWORK LIBRARIES
# ========================================

# Keep OkHttp3 classes completely
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keepnames class okhttp3.** { *; }

# Keep old OkHttp classes (com.squareup.okhttp) - used by some dependencies
-dontwarn com.squareup.okhttp.**
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }

# Keep Retrofit classes completely  
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepnames class retrofit2.** { *; }

# Keep Picasso and related classes
-keep class com.squareup.picasso.** { *; }
-dontwarn com.squareup.picasso.**

# ========================================
# ANDROID FRAMEWORK CLASSES
# ========================================

# Keep WebView related classes
-keep class android.webkit.** { *; }
-keep class * extends android.webkit.WebViewClient { *; }
-keep class * extends android.webkit.WebChromeClient { *; }

# Keep custom view classes with all constructors
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public <init>(android.content.Context, android.util.AttributeSet, int, int);
    public void set*(...);
    *** get*();
    <fields>;
    <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
    <fields>;
    <methods>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
    **[] $VALUES;
    public *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ========================================
# ESSENTIAL ATTRIBUTES
# ========================================

# Keep all annotations and signatures for runtime reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Keep source file names and line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable

# ========================================
# PREVENT COMMON ISSUES
# ========================================

# Keep classes that might be instantiated via reflection
-keep class * {
    public <init>();
    public <init>(...);
}

# Additional safety rules to prevent ClassCastException
-keep,allowshrinking,allowoptimization class * {
    <fields>;
}

# ========================================
# MISSING CLASSES - IGNORE WARNINGS FOR NON-ESSENTIAL CLASSES
# ========================================

# Google Play Core classes - ignore warnings (not essential for basic functionality)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Old OkHttp (com.squareup.okhttp) - ignore warnings for Picasso compatibility
-dontwarn com.squareup.okhttp.**

# Java beans classes - ignore warnings (not available on Android)
-dontwarn java.beans.**

# Jackson databind classes - ignore warnings
-dontwarn com.fasterxml.jackson.**

# Other JVM-specific classes not available on Android
-dontwarn java.lang.instrument.**
-dontwarn sun.misc.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Ignore warnings for classes that may not be available in all Android versions
-dontwarn android.support.**
-dontwarn androidx.annotation.Keep
