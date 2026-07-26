import 'package:flutter/material.dart';
import '../models/user.dart';

class StudentCard extends StatelessWidget {
  final User student;
  final VoidCallback? onTap;
  const StudentCard({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(student.fullName),
        subtitle: Text('الحضور: --%'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}