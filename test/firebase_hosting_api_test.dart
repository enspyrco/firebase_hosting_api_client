import 'package:firebase_hosting_api_client/src/firebase_hosting_api_client.dart';
import 'package:test/test.dart';

void main() {
  test('Firebase Hosting API', () {
    String key = '';

    expect(() => FirebaseHostingApiClient.create(serviceAccountKey: key),
        throwsException);
  });
}
