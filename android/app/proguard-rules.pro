# Stripe related rules
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

-keep class androidx.media3.** { *; }

# Explicitly keep ExoPlayer Ads modules (VAST ads)
-keep class androidx.media3.exoplayer.ads.** { *; }
-keep class androidx.media3.exoplayer.source.ads.** { *; }

# Explicitly keep Progressive (MP4) source & extractors
-keep class androidx.media3.exoplayer.source.ProgressiveMediaSource { *; }
-keep class androidx.media3.extractor.** { *; }

# Keep enums used reflectively
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}


# llfbandit.record related rules
-keep class com.llfbandit.record.** { *; }
-keep class com.llfbandit.record.record.format.Format { *; }

# General rules for Flutter and Kotlin
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-dontwarn io.flutter.plugins.**

# Keep all members of sealed classes
-keep class **.SealedClass { *; }

# Razorpay
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*
