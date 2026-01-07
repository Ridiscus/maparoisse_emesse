import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../app_themes.dart'; // Ton thème

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  // Liste de tes vidéos (URL ou Assets)
  final List<Map<String, String>> _tutorials = [
    {
      "title": "Comment demander une messe",
      "video": "assets/videos/tuto_request.mp4", // Ou URL distante
      "desc": "Apprenez étape par étape comment formuler votre intention."
    },
    {
      "title": "Effectuer un paiement",
      "video": "assets/videos/tuto_payment.mp4",
      "desc": "Sécurisez votre offrande via Mobile Money ou Carte."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tutoriels Vidéo"), // Localise ce texte
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tutorials.length,
        itemBuilder: (context, index) {
          final tuto = _tutorials[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            color: theme.cardTheme.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone de lecture (Placeholder avec icône Play pour l'instant)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: const DecorationImage(
                        image: AssetImage('assets/images/video_placeholder.jpg'), // Mets une image de fond
                        fit: BoxFit.cover,
                        opacity: 0.6
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                      onPressed: () {
                        // Ouvrir le lecteur plein écran
                        _playVideo(context, tuto['video']!);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tuto['title']!,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tuto['desc']!,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _playVideo(BuildContext context, String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoPath: videoPath)),
    );
  }
}

// Écran simple pour jouer la vidéo
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    // Si c'est un asset local :
    _videoPlayerController = VideoPlayerController.asset(widget.videoPath);
    // Si c'est une URL internet :
    // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));

    _videoPlayerController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
        );
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: _chewieController != null && _videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}