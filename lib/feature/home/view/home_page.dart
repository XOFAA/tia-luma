import 'package:flutter/material.dart';
import 'package:tia_luma/core/models/usuario_model.dart';
import 'package:tia_luma/feature/gamification/view/gamifcation_page.dart';


class HomePage extends StatefulWidget {
  final Usuario usuario;
 const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GamificationPage(usuario: widget.usuario), // agora funciona
      const Center(child: Text("Tickets", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Ranking", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Perfil", style: TextStyle(color: Colors.white))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0E0822),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Ranking"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
