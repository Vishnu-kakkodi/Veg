# --- Existing rules ---
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
    public void onPayment*(...);
}

# --- ML Kit text recognition rules ---
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# --- Optional: prevent warnings for ML Kit reflection calls ---
-dontwarn com.google.mlkit.**
