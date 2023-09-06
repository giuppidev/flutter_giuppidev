import 'package:flutter/material.dart';
import 'package:flutter_giuppidev/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required String this.title});

  final String title;

  Future<void> _signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
      );
    } finally {
      context.go("/");
    }
  }

  @override
  Size get preferredSize => Size(10, 60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      iconTheme: IconThemeData(color: Colors.black),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: Colors.black87,
          height: 5.0,
        ),
      ),
      backgroundColor: Color(0XFFFFCC33),
      titleTextStyle: const TextStyle(
          color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 20),
      actions: [
        IconButton(
          onPressed: () => _signOut(context),
          icon: const Icon(Icons.exit_to_app),
          color: Colors.black87,
        ),
      ],
    );
  }
}
