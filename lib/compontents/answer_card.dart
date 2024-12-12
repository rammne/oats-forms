import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  final String answer;

  const AnswerCard({
    Key? key,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5
        ),
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 8),
          Text(
            answer.isNotEmpty ? answer : 'No response',
            style: TextStyle(
              fontSize: 15,
              color: answer.isNotEmpty ? Colors.black : Colors.grey,
              fontStyle: answer.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}