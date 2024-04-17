import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/client.dart';
import '../../generated/l10n.dart';
import '../../input_token_dialog.dart';
import '../../login.dart';
import '../../store.dart';
import '../../user_provider.dart';
import '../index.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  SunoClient client = SunoClient();

  @override
  Widget build(BuildContext context) {
    Future<void> onLogin(String cookieString) async {
      client.applyCookie(cookieString);
      if (context.mounted) {
        final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loginUser(cookieString);
        AppDataStore().setLogoutFlag(false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => IndexPage()));
      }
    }



    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Login",style: TextStyle(fontSize: 32),),
            Container(
              margin: const EdgeInsets.only(top: 32),
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  if (result != null) {
                    onLogin(result);
                  }
                },
                child: const Text('UserLogin'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              child: FilledButton(
                  onPressed: () {
                    showCookieInputDialog(context,
                        title: S.of(context).InputCookieDialog_Title,
                        onOk: (cookieString) async {
                      await onLogin(cookieString);
                    });
                  },
                  child: Text('InputCookie')
              ),
            ),
          ],
        ),
      ),
    );
  }
}
