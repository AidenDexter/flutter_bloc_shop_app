import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_groupchat/pages/sign_in/bloc/sign_in_blocs.dart';

import '../../common/widgets/flutter_toast.dart';

class SignInController {
  final BuildContext context;
  const SignInController({
    required this.context,
  });

  void handleSignIn(String type) async {
    try {
      if (type == 'email') {
        //BlocProvider.of<SignInBloc>(context).state
        final state = context.read<SignInBloc>().state;
        String emailAddress = state.email;
        String password = state.password;
        if (emailAddress.isEmpty) {
          //
          toastInfo(msg: 'Fill email address.');
          return;
        }
        if (password.isEmpty) {
          //
          toastInfo(msg: 'Fill password.');
          return;
        }

        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
          if (credential.user == null) {
            //
            toastInfo(msg: 'user does not exist');
            return;
          }
          if (!credential.user!.emailVerified) {
            //
            toastInfo(msg: 'You need to verify your email account');
            return;
          }

          var user = credential.user;
          if (user != null) {
            //we got verified user from Firebase
            print(('user exist'));
            Navigator.of(context).pushNamedAndRemoveUntil('/application', (route) => false);
          } else {
            //we have error getting user from firebase
            toastInfo(msg: 'Currently you are not a user of this app');
            return;
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email');
            toastInfo(msg: 'No user found for that email');
            return;
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user');
            toastInfo(msg: 'Wrong password provided for that user');
            return;
          } else if (e.code == 'invalid-email') {
            print('Your email format is wrong');
            toastInfo(msg: 'Your email format is wrong');
            return;
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
