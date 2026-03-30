import 'package:flutter/material.dart';

class ReadButton extends StatelessWidget {
  const ReadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(0, 85, 255, 1),
            Color.fromRGBO(73, 213, 255, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.only(bottom: 2),
          ),
          child: Text(
            'Read now',
            style: TextStyle(fontFamily: 'SF Pro', fontSize: 12),
          ),
        ),
      ),
    );
  }
}
