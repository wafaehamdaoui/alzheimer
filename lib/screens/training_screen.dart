import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myproject/models/memory_card.dart';

class MemoryGameScreen extends StatefulWidget {
  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> _cards = [];
  MemoryCard? _firstCard;
  MemoryCard? _secondCard;
  int _matchedCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<String> images = [
      'assets/img/card1.png',
      'assets/img/card2.png',
      'assets/img/card3.png',
      'assets/img/card4.png',
      'assets/img/card5.png',
      'assets/img/card6.png',
      'assets/img/card7.png',
      'assets/img/card8.png',
      //'assets/img/card9.png',
      'assets/img/card10.png',
      'assets/img/card11.png',
      'assets/img/card12.png',
      'assets/img/card14.png',
      'assets/img/card13.png',
      //'assets/img/card15.png',
      'assets/img/card16.png',
    ];

    // Create pairs of cards
    List<MemoryCard> tempCards = [];
    for (String image in images) {
      String id = UniqueKey().toString();
      tempCards.add(MemoryCard(image: image, id: id));
      tempCards.add(MemoryCard(image: image, id: id)); // Add a pair
    }

    // Shuffle the cards
    tempCards.shuffle(Random());
    _cards = tempCards;
  }

  void _onCardTapped(MemoryCard card) {
    if (card.isFaceUp || _secondCard != null) return;

    setState(() {
      card.isFaceUp = true;

      if (_firstCard == null) {
        _firstCard = card;
      } else {
        _secondCard = card;
        _checkForMatch();
      }
    });
  }

  void _checkForMatch() {
    if (_firstCard!.image == _secondCard!.image) {
      setState(() {
        _matchedCount++;
        _firstCard!.isMatched = true;
        _secondCard!.isMatched = true;
        _firstCard = null;
        _secondCard = null;
      });
    } else {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _firstCard!.isFaceUp = false;
          _secondCard!.isFaceUp = false;
          _firstCard = null;
          _secondCard = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Matching Game'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.only(top: 40,left: 5, right: 5),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return GestureDetector(
            onTap: () => _onCardTapped(card),
            child: Card(
              color: card.isFaceUp || card.isMatched
                  ? Colors.white
                  : Color.fromARGB(255, 163, 33, 243),
              child: Center(
                child: card.isFaceUp || card.isMatched
                    ? Image.asset(card.image)
                    : const Icon(Icons.help_outline, size: 50),
              ),
            ),
          );
        },
      ),
    );
  }
}
