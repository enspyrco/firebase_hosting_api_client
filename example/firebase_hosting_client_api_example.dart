import 'package:firebase_hosting_api_client/client.dart';

void main() async {
  var client = await FirebaseHostingApiClient.create(
      serviceAccountKey: 'get a key from gcp console');
  client;
}
