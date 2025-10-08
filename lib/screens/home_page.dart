import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final Color active = Color.fromRGBO(0, 85, 255, 1);
  final Color inactive = Colors.white;

  final List<String> labels = const ['Home', 'Search', 'Collection', 'Setting'];
  final List<double> labelDx = [0, 0, 0, 0]; // + move to the right, - move to the left
  final double labelDy = 0; // + move down, - move up

  Widget label(String label, int idx) {
    final selected = index == idx;
    return Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? active : inactive));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CurvedNavigationBar(
            color: Colors.black,
            buttonBackgroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            items: [
              Icon(Icons.home, size: 30 ,color: index == 0 ? active : Colors.white),
              Icon(Icons.search, size: 30 ,color: index == 1 ? active : Colors.white),
              Icon(Icons.book, size: 30 ,color: index == 2 ? active : Colors.white),
              Icon(Icons.settings, size: 30 ,color: index == 3 ? active : Colors.white),
            ],
            index: index,
            onTap: (i) => setState(() => index = i),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(labels.length, (i) {
                  return Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Transform.translate(
                        offset: Offset(
                          i < labelDx.length ? labelDx[i] : 0, labelDy,
                        ),
                        child: label(labels[i], i),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(180, 225, 255, 1),
              Color.fromRGBO(243, 255, 181, 1),
              Colors.white,
            ]
          ),
        ),
      ),
    );
  }
}
