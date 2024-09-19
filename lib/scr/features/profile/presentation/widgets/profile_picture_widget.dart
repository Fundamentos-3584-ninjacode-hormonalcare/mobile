import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final bool isEditing;
  final VoidCallback toggleEditMode;

  const ProfilePictureWidget({
    Key? key,
    required this.isEditing,
    required this.toggleEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF40535B),
          child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
        ),
       // if (!isEditing)
       //   Positioned(
       //     bottom: 0,
       //     right: 0,
       //     child: IconButton(
       //       icon: Icon(Icons.edit, color: Colors.grey[600]),
       //       onPressed: toggleEditMode,
       //     ),
       //   ),
      ],
    );
  }
}
