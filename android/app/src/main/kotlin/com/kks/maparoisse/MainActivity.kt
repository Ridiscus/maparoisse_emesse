package com.kks.maparoisse

import android.os.Bundle // <--- Ajouté
import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat // <--- Ajouté pour gérer le bord à bord

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Aligne le contenu de la fenêtre pour qu'il soit "Edge-to-Edge"
        // Cela désactive les barres systèmes opaques par défaut d'Android
        WindowCompat.setDecorFitsSystemWindows(window, false)

        super.onCreate(savedInstanceState)
    }
}