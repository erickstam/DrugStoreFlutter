import 'package:drugstore/Components/square_tite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drugstore/Components/my_textfield.dart';
import 'package:drugstore/Components/my_botton.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //Sign user in method
  void signUserIn() async{
    // show loading circle
    showDialog(context: context, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

    // try sign in
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: usernameController.text, 
      password: passwordController.text);
    }on FirebaseException catch (e){
      /*if (e.code == 'user-not-found'){
        print('No user fount for that Email');//On validate terminal error
        WrongEmailMessage();
      } else if (e.code == 'wrong-password'){
        print('Wrong password buddy');//On validate terminal error
        WrongPasswordMessage();
      }*/
      // wrong password or email
      showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              e.code, 
              style:  const TextStyle(color: Colors.white),
            ),
          ),
        );
      });
    }
    //pop the loading circle -> stop
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                //logo
                const Icon(
                  Icons.lock,
                  size: 55,
                ),
                const SizedBox(height: 20),
                //welcome back, you've been missed!
                const Text(
                  'Welcome to your Drug Store app',
                  style: TextStyle(
                    color: Color.fromARGB(255, 147, 149, 150),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                //username textfield
                ImputTextMaterial(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                //password textfield
                ImputTextMaterial(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                //forgot password?
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style:
                            TextStyle(color: Color.fromARGB(255, 147, 149, 150)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //sign in button
                ButtonsMaterial(
                  text: "Sign In",
                  onTap: signUserIn,
                ),
                const SizedBox(height: 20),
                //or continue with
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 147, 149, 150),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //google sign in buttons
            
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: 'assets/Google.png'),
                  ],
                ),
                const SizedBox(height: 20),
                //not a member? regster now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member? ', style: TextStyle(color: Colors.blue)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}