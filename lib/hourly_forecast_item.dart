import 'package:flutter/material.dart';

class HourlyForecaseItem extends StatelessWidget {
  final String time, temp;
  final IconData icon;
  const HourlyForecaseItem({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child:  Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
           const SizedBox(
              height: 8,
            ),
           Icon(icon),
           const SizedBox(
              height: 8,
            ),
            Text(temp),
          ],
        ),
      ),
    );
  }
}
