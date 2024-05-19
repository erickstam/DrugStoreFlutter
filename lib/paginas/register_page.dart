import 'package:drugstore/Components/square_tite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drugstore/Components/my_textfield.dart';
import 'package:drugstore/Components/my_botton.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //Sign user up method
  void signUserUp() async{
    // show loading circle
    showDialog(context: context, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

    // try create user
    try{
      //check if password is confirm
      if (passwordController.text == confirmPasswordController.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernameController.text, 
        password: passwordController.text);
      }else{
        //show error message if password isnt equals
        //WrongErrorMessage("Password don't match");
        showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Password don\'t match', 
              style:  const TextStyle(color: Colors.white),
            ),
          ),
        );
      });
      }
    }on FirebaseException catch (e){
      //WrongErrorMessage(e.code);
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

  // wrong email/password message popup
  // No esta funcionando
/*  void WrongErrorMessage(String message){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message, 
              style:  const TextStyle(color: Colors.white),
            ),
          ),
        );
      });
  }*/
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
                Image.asset(
                  'assets/Drugstore.png', // Reemplaza 'ruta_de_tu_imagen' con la ruta de la imagen en tu proyecto
                  width: 500, // Ancho deseado de la imagen
                  height: 500, // Alto deseado de la imagen
                ),
                const SizedBox(height: 20),
                //lets create an account 
                const Text(
                  'Registrate en DrugStore',
                  style: TextStyle(
                    color: Color.fromARGB(255, 147, 149, 150),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                //username textfield
                ImputTextMaterial(
                  controller: usernameController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                //password textfield
                ImputTextMaterial(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                //confirm password textfield
                ImputTextMaterial(
                  controller: confirmPasswordController,
                  hintText: 'Confirmar contraseña',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                //sign in button
                ButtonsMaterial(
                  text: "Registrarse",
                  onTap: signUserUp,
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
                          'o continua con',
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
                //google + apple sign in buttons
            
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
                    const Text('ya tienes cuenta? ', style: TextStyle(color: Colors.blue)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Logueate ahora',
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