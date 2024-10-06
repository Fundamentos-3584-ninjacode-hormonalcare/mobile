import 'package:flutter/material.dart';

class UserInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF40535B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/images/user_avatar.png'), // Replace with actual image path
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Age: 30',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}