import 'package:financial_records/shared/shared_preferences.dart';
import 'package:financial_records/shared/snackbar.dart';
import 'package:financial_records/shared/theme.dart';
import 'package:financial_records/ui/widgets/buttons.dart';
import 'package:financial_records/ui/widgets/forms.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void login(BuildContext ctx, String email, String pass) async {
    if (email.isEmpty && pass.isEmpty) {
      CustomSnackbar.showToast(ctx, 'Inputan masih kosong!');
    } else {
      String pEmail = await SharedPrefUtils.readEmail();
      String pPassword = await SharedPrefUtils.readPassword();
      if (email == pEmail && pass == pPassword) {
        Navigator.pushNamedAndRemoveUntil(ctx, '/menu', (route) => false);
      } else {
        CustomSnackbar.showToast(ctx, 'Login Gagal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailCotroller = TextEditingController();
    final TextEditingController passwordCotroller = TextEditingController();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Container(
            width: 247,
            height: 187.34,
            margin: const EdgeInsets.only(top: 70, bottom: 80),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/LogoMedev.png'),
              ),
            ),
          ),
          Text(
            'Sign In & gayai hidup anda',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: whiteColor),
            child: Column(
              children: [
                CustomFormField(
                    title: 'Alamat Email', controller: emailCotroller),
                const SizedBox(
                  height: 8,
                ),
                CustomFormField(
                  title: 'Password',
                  obscureText: true,
                  controller: passwordCotroller,
                ),
                const SizedBox(
                  height: 38,
                ),
                CustomFillButton(
                    title: 'Sign In',
                    onPressed: () {
                      login(
                          context, emailCotroller.text, passwordCotroller.text);
                    })
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          CustomTextButton(
              title: 'Buat akun baru',
              onPressed: () {
                Navigator.pushNamed(context, '/sign-up');
              })
        ],
      ),
    );
  }
}
