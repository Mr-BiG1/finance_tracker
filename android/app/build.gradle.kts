plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // ✅ Firebase plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // ✅ Flutter plugin
}

android {
    namespace = "com.example.finance_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Ensure correct NDK version

    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // ✅ Enables Java 8+ features
        sourceCompatibility = JavaVersion.VERSION_17  // ✅ Set Java 17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // ✅ Ensure JVM target is 17
    }

    defaultConfig {
        applicationId = "com.example.finance_tracker"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // 🚀 Temporary signing config
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ UPDATED
}


// dependencies {
//     coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3") // ✅ Correct
// }