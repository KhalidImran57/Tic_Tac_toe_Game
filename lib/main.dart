import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static final headingStyle = GoogleFonts.coiny(
    color: Colors.deepOrangeAccent,
    letterSpacing: 2,
    fontSize: 28,
  );

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  final List<int> _board = List.filled(9, 0);
  bool _xTurn = true;
  bool _gameOver = false;
  String _message = "X's turn";
  int _scoreX = 0;
  int _scoreO = 0;

  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _resetBoard({bool fullReset = false}) {
    setState(() {
      for (var i = 0; i < 9; i++) _board[i] = 0;
      _xTurn = true;
      _gameOver = false;
      _message = "X's turn";
      if (fullReset) {
        _scoreX = 0;
        _scoreO = 0;
      }
    });
  }

  void _handleTap(int index) {
    if (_board[index] != 0 || _gameOver) return;

    setState(() {
      _board[index] = _xTurn ? 1 : 2;
      _xTurn = !_xTurn;
      _checkGameState();
      if (!_gameOver) {
        _message = _xTurn ? "X's turn" : "O's turn";
      }
    });
  }

  void _checkGameState() {
    final winner = _getWinner();
    if (winner != 0) {
      _gameOver = true;
      _message = (winner == 1) ? 'X wins!' : 'O wins!';
      if (winner == 1) _scoreX++; else _scoreO++;
      _confettiController.forward(from: 0.0);
      _showResultDialog(_message);
      return;
    }

    if (!_board.contains(0)) {
      _gameOver = true;
      _message = 'It\'s a Draw!';
      _showResultDialog(_message);
    }
  }

  int _getWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var line in lines) {
      final a = line[0], b = line[1], c = line[2];
      if (_board[a] != 0 && _board[a] == _board[b] && _board[b] == _board[c]) {
        return _board[a];
      }
    }
    return 0;
  }

  Future<void> _showResultDialog(String title) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: GamePage.headingStyle.copyWith(fontSize: 24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score — X: $_scoreX  |  O: $_scoreO', style: GoogleFonts.poppins(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetBoard();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play Again',style: TextStyle(color: Colors.white,fontSize: 20),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(int index) {
    final value = _board[index];
    final showX = value == 1;
    final showO = value == 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: showX
            ? const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFFFF4E50)])
            : showO
            ? const LinearGradient(colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)])
            : null,
        color: showX || showO ? null : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleTap(index),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: value == 0
                ? SizedBox(key: ValueKey(0))
                : value == 1
                ? Text('X', key: ValueKey(1), style: GoogleFonts.coiny(fontSize: 52, color: Colors.white))
                : Text('O', key: ValueKey(2), style: GoogleFonts.coiny(fontSize: 52, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tic Tac Toe', style: GamePage.headingStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Reset scores & board',
            onPressed: () => _resetBoard(fullReset: true),
            icon: const Icon(Icons.refresh,color: Colors.white,size: 30,),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(_message, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 14),

              // Score Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scoreBox('X', _scoreX, const Color(0xFFFF7A18)),
                  _scoreBox('O', _scoreO, const Color(0xFF36D1DC)),
                ],
              ),

              const SizedBox(height: 40),

              // Game Board
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) => _buildCell(index),
                ),
              ),

              const SizedBox(height: 50),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _gameOver ? _resetBoard : () => setState(() { for (var i = 0; i < 9; i++) _board[i] = 0; _gameOver = false; _message = _xTurn ? "X's turn" : "O's turn"; }),
                    icon: const Icon(Icons.replay,color: Colors.white,),
                    label: const Text('Reset Board', style: TextStyle(color: Colors.white,fontSize: 20),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () => _resetBoard(fullReset: true),
                    icon: const Icon(Icons.delete_forever,color: Colors.white,),
                    label: const Text('Reset All',style: TextStyle(color: Colors.white,fontSize: 22),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer
              Text('Made with ❤️ by you — stylish UI', style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.8), width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.coiny(color: color, fontSize: 18)),
          const SizedBox(height: 6),
          Text('$score', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
