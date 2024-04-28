import 'package:drugstore/utils/global.color.dart';
import 'package:drugstore/widgets/buttom.global.dart';
import 'package:drugstore/widgets/text.form.global.dart';
import 'package:flutter/material.dart';

import '../widgets/social.login.dart';

class Login2 extends StatelessWidget {
   Login2({Key ? key}) : super(key: key);
   final TextEditingController emailController = TextEditingController();
   final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                      'DrugStore',
                    style: TextStyle(
                      color: globalColors.mainColor,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logeate para ingresar',
                      style: TextStyle(
                        color: globalColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormGlobal(controller: emailController,
                      text: 'Email',
                      obscure: false,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextFormGlobal(controller: passwordController,
                      text: 'Contraseña',
                      textInputType: TextInputType.text,
                      obscure: true,
                    ),
                    const SizedBox(height: 10),
                    const ButtonGlobal(),
                    const SizedBox(height: 25),
                    SocialLogin(),
                  ],
                )
              ],
            ),
          ),
        )
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '¿Aun no tienes una cuenta?',
            ),
            InkWell(
              child: Text(
                  ' Registrate',
                style: TextStyle(
                  color: globalColors.mainColor,
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
