import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeHomePage(),
    );
  }
}

class SnakeHomePage extends StatefulWidget {
  @override
  _SnakeHomePageState createState() => _SnakeHomePageState();
}

class _SnakeHomePageState extends State<SnakeHomePage> {
  static const int rowCount = 20;
  static const int columnCount = 20;
  static const Duration duration = Duration(milliseconds: 200);

  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(5, 5);
  String direction = 'RIGHT';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer?.cancel(); // Cancel previous timer to prevent multiple timers
    timer = Timer.periodic(duration, (Timer t) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    Point<int> newHead;
    switch (direction) {
      case 'UP':
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case 'DOWN':
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case 'LEFT':
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case 'RIGHT':
      default:
        newHead = Point(snake.first.x + 1, snake.first.y);
    }

    if (newHead == food) {
      snake.insert(0, newHead);
      generateFood();
    } else {
      snake.insert(0, newHead);
      snake.removeLast();
    }

    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columnCount ||
        newHead.y >= rowCount ||
        snake.sublist(1).contains(newHead)) {
      timer?.cancel();
      showGameOverDialog();
    }
  }

  void generateFood() {
    Random random = Random();
    do {
      food = Point(random.nextInt(columnCount), random.nextInt(rowCount));
    } while (snake.contains(
      food,
    )); // Ensure food does not spawn inside the snake
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score: ${snake.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      timer?.cancel();
      snake = [Point(10, 10)];
      direction = 'RIGHT';
      generateFood();
      startGame();
    });
  }

  void changeDirection(String newDirection) {
    if ((direction == 'UP' && newDirection == 'DOWN') ||
        (direction == 'DOWN' && newDirection == 'UP') ||
        (direction == 'LEFT' && newDirection == 'RIGHT') ||
        (direction == 'RIGHT' && newDirection == 'LEFT')) {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
              ),
              itemCount: rowCount * columnCount,
              itemBuilder: (context, index) {
                int x = index % columnCount;
                int y = index ~/ columnCount;
                Point<int> position = Point(x, y);
                bool isSnake = snake.contains(position);
                bool isFood = food == position;
                return Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color:
                        isSnake
                            ? Colors.green
                            : isFood
                            ? Colors.red
                            : Colors.grey[900],
                    shape: BoxShape.rectangle,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => changeDirection('UP'),
                      child: Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => changeDirection('LEFT'),
                      child: Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => changeDirection('RIGHT'),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => changeDirection('DOWN'),
                      child: Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
