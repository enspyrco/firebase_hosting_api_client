import 'package:firebase_hosting_api_client/src/models/upload_data.dart';
import 'package:test/test.dart';

void main() {
  group('UploadData', () {
    test('.createFrom() generates correct paths', () async {
      final upload = await UploadData.createFrom(path: 'lib');
      print(upload);
    });
  });
}
