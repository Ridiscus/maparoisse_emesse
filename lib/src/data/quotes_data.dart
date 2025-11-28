// Fichier : lib/data/quotes_data.dart

// Un modèle simple pour nos citations
class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});
}

// La liste complète de toutes vos citations
// J'en mets 3 en exemple, vous pouvez en ajouter jusqu'à 100 ou plus !
const List<Quote> allQuotes = [
  Quote(
      text: "Ne craignez pas, car je suis avec vous; ne vous inquiétez pas, car je suis votre Dieu.",
      author: "Ésaïe 41:10"
  ),
  Quote(
      text: "Le Seigneur est mon berger, je ne manquerai de rien.",
      author: "Psaume 23:1"
  ),
  Quote(
      text: "Je puis tout par celui qui me fortifie.",
      author: "Philippiens 4:13"
  ),
  Quote(
    text: "L'Éternel est mon berger: je ne manquerai de rien.",
    author: "Psaume 23:1",
  ),

  Quote(
    text: "Venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai du repos.",
    author: "Matthieu 11:28",
  ),

  Quote(
    text: "Je puis tout par celui qui me fortifie.",
    author: "Philippiens 4:13",
  ),

  Quote(
    text: "Car je connais les projets que j’ai formés sur vous, dit l’Éternel, projets de paix et non de malheur, afin de vous donner un avenir et de l’espérance.",
    author: "Jérémie 29:11",
  ),

  Quote(
    text: "Heureux ceux qui placent en toi leur appui! Ils trouvent dans leur cœur des chemins tout tracés.",
    author: "Psaume 84:5",
  ),

  Quote(
    text: "Dieu est pour nous un refuge et un appui, un secours qui ne manque jamais dans la détresse.",
    author: "Psaume 46:1",
  ),

  Quote(
    text: "L’amour est patient, il est plein de bonté; l’amour n’est point envieux.",
    author: "1 Corinthiens 13:4",
  ),

  Quote(
    text: "Si Dieu est pour nous, qui sera contre nous?",
    author: "Romains 8:31",
  ),

  Quote(
    text: "Louez l’Éternel, car il est bon, car sa miséricorde dure à toujours!",
    author: "Psaume 136:1",
  ),

  Quote(
    text: "Ne vous inquiétez de rien; mais en toute chose faites connaître vos besoins à Dieu par des prières et des supplications, avec des actions de grâces.",
    author: "Philippiens 4:6",
  ),
  // <-- AJOUTEZ VOS 97 AUTRES CITATIONS ICI -->
];