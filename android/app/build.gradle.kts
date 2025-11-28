import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. CHARGEMENT SÉCURISÉ DU FICHIER KEY.PROPERTIES
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kks.maparoisse"

    // On garde ta version 36 si tu as mis à jour le SDK, sinon remets 34 ou 35
    compileSdk = 36

    defaultConfig {
        applicationId = "com.kks.maparoisse"

        // J'ai remis 21 en dur pour éviter les erreurs de lecture de variable flutter
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    // 2. CONFIGURATION DE LA SIGNATURE
    signingConfigs {
        create("release") {
            // On vérifie que le fichier a bien été chargé pour éviter un crash
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // 3. APPLIQUER LA SIGNATURE RELEASE
            // On applique la config seulement si elle existe
            signingConfig = signingConfigs.getByName("release")

            // Options pour réduire la taille
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }



    packaging {
        jniLibs {
            // Cela force la compression des lib natives.
            // Google Play ne t'embêtera plus avec l'alignement 16 Ko.
            useLegacyPackaging = true
        }
    }



    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.multidex:multidex:2.0.1")
}
