import 'package:drugstore/paginas/login_page.dart';
import 'package:drugstore/paginas/register_page.dart';
import 'package:flutter/material.dart';

class LoginOnRegisterPage extends StatefulWidget {
  const LoginOnRegisterPage({super.key});

  @override
  State<LoginOnRegisterPage> createState() => _LoginOnRegisterPageState();
}

class _LoginOnRegisterPageState extends State<LoginOnRegisterPage> {

  //initially show login page
  bool showLoginPage = true;
  // toggle between login and register page
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(
        onTap:  togglePages,
      );
    }else{
      return RegisterPage(
        onTap:  togglePages,
      );
    }
  }
}