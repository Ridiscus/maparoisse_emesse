pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // ON PASSE EN 8.5.0 (Version très stable et récente)
    id("com.android.application") version "8.5.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    // ON MET À JOUR KOTLIN EN 1.9.24 (Requis par les nouveaux plugins)
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
include(":app")