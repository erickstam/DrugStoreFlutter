import 'package:drugstore/Paginas/login_or_registerPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData){// user in logged in
            return HomePage();
          }else{// user is NOT logged in
            //return LoginPage();
            return const LoginOnRegisterPage();
          }
        }
      ),
    );
  }
}