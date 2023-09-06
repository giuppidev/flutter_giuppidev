import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_giuppidev/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _FormState();
}

class _FormState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _redirecting = false;
  bool _loading = false;

  Future<void> _signinAPI() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.auth.signInWithPassword(
            password: passwordController.text, email: emailController.text);
      } on AuthException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("errore"),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _authStateSubscription =
        supabase.auth.onAuthStateChange.listen((data) async {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        try {
          final sub = await supabase
              .from("subscriptions")
              .select()
              .eq("email", session.user.email)
              .eq("active", true)
              .single();
          _redirecting = true;
          context.go('/courses');
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Not subscribed to the academy!"),
              );
            },
          );

          supabase.auth.signOut();
        }
      }
    });
    super.initState();
  }

  Future<void> _signUp() async {
    Uri uri = Uri.parse("https://giuppi.dev/#subscription");
    if (!await launchUrl(uri)) {
      throw Exception("Cannot launch url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xFFFFCC33),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/logo.svg',
                    semanticsLabel: 'giuppidev Logo', width: 300),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black87, width: 4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Email",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const Divider(),
                                        TextFormField(
                                          controller: emailController,
                                          validator: (value) {
                                            if (!EmailValidator.validate(
                                                value ?? "")) {
                                              return "Email not valid";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              hintText: "giuppi@mail.dev",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xffFFCC33),
                                                      width: 4)),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black87,
                                                      width: 4))),
                                        ),
                                      ]),
                                  const SizedBox(height: 24),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Password",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const Divider(),
                                        TextFormField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                              hintText: "12345678",
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xffFFCC33),
                                                      width: 4)),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black87,
                                                      width: 4))),
                                        ),
                                      ]),
                                  const SizedBox(height: 12),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            color: Colors.black87, width: 4),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black87,
                                            spreadRadius: 1,

                                            offset: Offset(4,
                                                4), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _signinAPI,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF6D9022),
                                          minimumSize: const Size(20, 60),
                                        ),
                                        child: const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            fontSize: 30,
                                          ),
                                        ),
                                      ))
                                ],
                              )),
                        ))),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                      text: "Non sei iscritto? Vai ",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black)),
                  TextSpan(
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade400),
                      text: "qui",
                      recognizer: TapGestureRecognizer()..onTap = _signUp)
                ])),
              ],
            ))));
  }
}

class Logged extends StatelessWidget {
  const Logged({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Welcome!")),
        body: Text("Welcome back $username!"));
  }
}
