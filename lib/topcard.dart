import 'package:flutter/material.dart';

class TopNewCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color :Colors.grey[300],
      child: Center(
        child:Column(
          children: [
          Text(
                'BALANCE',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

          ],
        )
      ),
    );
  }
}
