import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (gitignored) is written by CI or created locally.
// See docs/RELEASING.md. Without it, a release build is refused (below) rather than
// silently falling back to the debug keys, unless that fallback is explicitly asked for.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// `flutter run --release` and a local test build still need to work without a keystore,
// so the missing-keys case is only a hard failure when a release build is actually being
// assembled -- checked once the task graph is known, not at configuration time, so
// `flutter build apk --debug` and `flutter test` are never affected by this at all -- and
// only when neither escape hatch is given: `-PallowDebugSigning=true` locally, or the `CI`
// environment variable GitHub Actions sets, for a workflow that provides its own keys.
val allowDebugSigning = (project.findProperty("allowDebugSigning") as String?) == "true" ||
    System.getenv("CI") == "true"

gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { task ->
        task.project == project && task.name.contains("Release")
    }
    if (buildingRelease && !keystorePropertiesFile.exists() && !allowDebugSigning) {
        throw GradleException(
            "android/key.properties not found: a release build would be debug-signed " +
                "and Play Console would reject it. See docs/RELEASING.md, or pass " +
                "-PallowDebugSigning=true for a local debug-signed test build.",
        )
    }
}

android {
    namespace = "com.oasisforge.monthlyexpenses"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (note reminders, NOTE-6) needs this.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // The store ID; it can't change after the first Play upload.
        applicationId = "com.oasisforge.monthlyexpenses"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Named explicitly rather than trusting the Flutter plugin to pick
            // the file up: without its rule, the release build crashes at
            // launch (see the file).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Debug keys so `flutter run --release` works before a keystore exists.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // For isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
