import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureWidget extends StatefulWidget {
  final bool isEditing;
  final VoidCallback toggleEditMode;
  final String? imageUrl;
  final Function(File)? onImageSelected; // <- NUEVO

  const ProfilePictureWidget({
    Key? key,
    required this.isEditing,
    required this.toggleEditMode,
    this.imageUrl,
    this.onImageSelected, // <- NUEVO
  }) : super(key: key);

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Llamar al callback para subir imagen
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(_selectedImage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEditing ? _pickImage : widget.toggleEditMode,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : (widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            ? NetworkImage(widget.imageUrl!) as ImageProvider
            : null),
        child: (_selectedImage == null &&
            (widget.imageUrl == null || widget.imageUrl!.isEmpty))
            ? Icon(Icons.person, size: 50)
            : null,
      ),
    );
  }
}
