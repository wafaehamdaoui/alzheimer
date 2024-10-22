class MemoryCard {
  final String image;
  final String id;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.image,
    required this.id,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}
