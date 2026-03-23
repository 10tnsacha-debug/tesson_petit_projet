import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://192.168.1.44:8090');

class AuthApi {
  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<void> register(String email, String password) async {
    await pb
        .collection('users')
        .create(
          body: {
            "email": email,
            "password": password,
            "passwordConfirm": password,
          },
        );
  }

  bool get isLoggedIn => pb.authStore.isValid;

  void logout() {
    pb.authStore.clear();
  }
}
