import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const AdditionalInfoItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          label,
          style:  TextStyle(
            //  fontSize: 20,
            color: Theme.of(context).brightness==Brightness.dark? Colors.grey:Colors.black,
          ),
        ),
       const SizedBox(
          height: 8,
        ),
        Text(
          value,
          style:  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness==Brightness.dark? Colors.grey:Colors.black54,
          ),
        ),
      ],
    );
  }
}
