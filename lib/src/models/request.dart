class Request {
  final String id;
  final String intention;
  final String motif;
  final String paroisse;
  final String celebration;
  final String date;
  final String status;

  // --- MODIFICATION 1 : Ajout des nouveaux champs ---
  // On utilise 'double?' pour indiquer que ces champs peuvent être nuls
  // (par exemple, si une demande très ancienne n'a pas ces infos).
  final double? montant;
  final double? frais;
  final double? total;

  Request({
    required this.id,
    required this.intention,
    required this.motif,
    required this.paroisse,
    required this.celebration,
    required this.date,
    required this.status,
    // --- MODIFICATION 2 : Ajout des champs au constructeur ---
    this.montant,
    this.frais,
    this.total,
  });


  // --- AJOUTEZ TOUTE CETTE FONCTION CI-DESSOUS ---
  Request copyWith({
    String? id,
    String? intention,
    String? motif,
    String? paroisse,
    String? celebration,
    String? date,
    String? status,
    double? montant,
    double? frais,
    double? total,
  }) {
    return Request(
      id: id ?? this.id,
      intention: intention ?? this.intention,
      motif: motif ?? this.motif,
      paroisse: paroisse ?? this.paroisse,
      celebration: celebration ?? this.celebration,
      date: date ?? this.date,
      status: status ?? this.status,
      montant: montant ?? this.montant,
      frais: frais ?? this.frais,
      total: total ?? this.total,
    );
  }
  // --- FIN DE L'AJOUT ---




  // Conversion Map <-> Object (pour SharedPreferences ou Firebase)
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] ?? '',
      intention: map['intention'] ?? '',
      motif: map['motif'] ?? '',
      paroisse: map['paroisse'] ?? '',
      celebration: map['celebration'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? '',
      // --- MODIFICATION 4 : Lecture des nouveaux champs depuis la Map ---
      // On utilise (map['...'] as num?)?.toDouble() pour convertir
      // de manière sûre un nombre (entier ou à virgule) en double.
      montant: (map['montant'] as num?)?.toDouble(),
      frais: (map['frais'] as num?)?.toDouble(),
      total: (map['total'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'intention': intention,
      'motif': motif,
      'paroisse': paroisse,
      'celebration': celebration,
      'date': date,
      'status': status,
      // --- MODIFICATION 3 : Ajout des nouveaux champs à la Map ---
      'montant': montant,
      'frais': frais,
      'total': total,
    };
  }
}