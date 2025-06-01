import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:swimaca/Screen/Register.dart';
import 'package:swimaca/Screen/HomePage.dart';
import 'package:swimaca/AdminScreen/AdminHome.dart';
class AvtorizScreen extends StatefulWidget {
  const AvtorizScreen({super.key});

  @override
  _AvtorizScreenState createState() => _AvtorizScreenState();
}

class _AvtorizScreenState extends State<AvtorizScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля.")),
      );
      return;
    }

    // 👇 Проверка на admin
    if (email == 'admin' && password == '12345678') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHome()),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userData = await _getUserData(user.uid);
        if (userData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Успешная авторизация!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Данные пользователя не найдены.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ошибка авторизации.";
      if (e.code == 'user-not-found') {
        errorMessage = "Пользователь с таким email не найден.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Неверный пароль.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Некорректный email.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Произошла ошибка: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Получаем данные пользователя из Realtime Database
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    final snapshot = await _database.child('users/$userId').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Авторизация",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Пароль",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onConfirm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Войти",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Нет аккаунта? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Зарегистрироваться',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}