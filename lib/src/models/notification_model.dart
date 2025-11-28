class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data; // Champ pour la navigation

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.data,
  });



  factory NotificationModel.fromJson(Map<String, dynamic> json) {

    // 1. CORRECTION DATE : On lit 'created_at'
    DateTime parsedDate;
    try {
      // Le JSON contient "created_at": "2025-11-24T13:14:00.000000Z"
      final String? dateStr = json['created_at']?.toString();

      if (dateStr != null) {
        parsedDate = DateTime.parse(dateStr);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      print("Erreur date: $e");
      parsedDate = DateTime.now();
    }

    // 2. CORRECTION ID LIÉ (messe_id est à la racine dans ton JSON)
    // On convertit en String car le JSON envoie un int (6)
    String? relatedId = json['messe_id']?.toString()
        ?? json['event_id']?.toString()
        ?? json['request_id']?.toString();

    // 3. Gestion de 'data' (Ton JSON montre que c'est une liste vide [], pas une Map)
    // On sécurise pour ne pas planter si c'est une liste
    Map<String, dynamic>? dataMap;
    if (json['data'] is Map<String, dynamic>) {
      dataMap = json['data'];
    }

    return NotificationModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),

      // Les infos sont à la racine dans ton JSON
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',

      timestamp: parsedDate, // ✅ Utilise la date corrigée (created_at)

      // Lecture du statut de lecture
      isRead: json['read_at'] != null,

      type: json['type']?.toString() ?? 'general',

      // On stocke l'ID lié qu'on a trouvé à la racine
      // (Si tu as un champ relatedId dans ta classe, décommente la ligne suivante)
      // relatedId: relatedId,

      // On reconstruit une map de data utile pour la navigation
      data: dataMap ?? {
        'messe_id': relatedId,
        'type': json['type']
      },
    );
  }





  // Copie pour marquer comme lu
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      data: data,
    );
  }
}