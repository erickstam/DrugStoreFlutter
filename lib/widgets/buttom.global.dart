import 'package:drugstore/utils/global.color.dart';
import 'package:flutter/material.dart';

class ButtonGlobal extends StatelessWidget {
  const ButtonGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            print('Login');
          },
          child: Container(
            alignment: Alignment.center,
            height: 55,
            margin: EdgeInsets.symmetric(vertical: 10), // Espacio entre los botones
            decoration: BoxDecoration(
              color: globalColors.mainColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'Ingresar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
