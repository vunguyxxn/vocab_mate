plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vocabmate.vocab_mate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // 🔥 BẮT BUỘC cho flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.vocabmate.vocab_mate"

        minSdk = flutter.minSdkVersion   // 🔥 QUAN TRỌNG (nếu thấp hơn sẽ lỗi tiếp)
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 🔥 THƯ VIỆN GIÚP CHẠY JAVA 8+ FEATURES TRÊN ANDROID
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
