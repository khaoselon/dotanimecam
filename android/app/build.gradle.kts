plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dotanimecam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.dotanimecam"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
                // カメラ機能が必要
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // 署名設定（実際の配布時に設定）
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("production") {
            dimension = "default"
            applicationIdSuffix = ""
            versionNameSuffix = ""
        }
        
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
        }
    }

    // パフォーマンス最適化
    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    // リソース設定
    androidResources {
        generateLocaleConfig = true
    }

    // セキュリティ設定
    packagingOptions {
        pickFirst("**/libc++_shared.so")
        pickFirst("**/libjsc.so")
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.1")
    implementation("androidx.activity:activity-compose:1.7.2")
    
    // カメラ関連
    implementation("androidx.camera:camera-core:1.2.3")
    implementation("androidx.camera:camera-camera2:1.2.3")
    implementation("androidx.camera:camera-lifecycle:1.2.3")
    implementation("androidx.camera:camera-video:1.2.3")
    implementation("androidx.camera:camera-view:1.2.3")
    implementation("androidx.camera:camera-extensions:1.2.3")
    
    // 画像処理
    implementation("androidx.exifinterface:exifinterface:1.3.6")
    
    // ファイル操作
    implementation("androidx.documentfile:documentfile:1.0.1")
    
    // Google Play Services
    implementation("com.google.android.gms:play-services-ads:22.4.0")
    implementation("com.google.android.gms:play-services-base:18.2.0")
    
    // UI
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    
    // パフォーマンス監視
    implementation("androidx.tracing:tracing:1.1.0")
    
    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}

// ProGuard設定
configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.10.1")
    }
}