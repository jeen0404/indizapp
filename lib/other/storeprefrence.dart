import 'package:shared_preferences/shared_preferences.dart';

class storeprefrence{

   storeemailuid(email,uid) async{
     var prefs = SharedPreferences.getInstance() as SharedPreferences;
     prefs.setString("uid",uid);
     prefs.setString("email",email);
  }

}