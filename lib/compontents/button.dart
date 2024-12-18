import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Function() onSubmit;
  final bool enabled;
  const Button({
    super.key,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: enabled == true
          ? InkWell(
            onTap: onSubmit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 250, vertical: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: const Color.fromRGBO(11, 10, 95, 1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text(
                'S U B M I T',
                style: TextStyle(
                  color: Color.fromARGB(255, 253, 216, 83),
                ),
              ),
            ),
          )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 250, vertical: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6)),
              child: const Text(
                'S U B M I T',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
      ),
    );
  }
}
