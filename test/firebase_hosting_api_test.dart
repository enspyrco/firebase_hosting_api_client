import 'dart:io';

import 'package:firebase_hosting_api_client/client.dart';
import 'package:firebase_hosting_api_client/src/firebase_hosting_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Firebase Hosting API', () {
    test('throws if created with bad key', () async {
      expect(
          () => FirebaseHostingApiClient.create(
              serviceAccountKey: '', projectId: 'enspyrco'),
          throwsException);
    });

    test('retrieves the current version', () async {
      String key = File('test/key.string').readAsStringSync();
      var client = await FirebaseHostingApiClient.create(
          serviceAccountKey: key, projectId: 'enspyrco');

      var currentVersion = await client.getCurrentVersion();

      print(currentVersion);
    });

    test('retrieves current files for a version', () async {
      String key = File('test/key.string').readAsStringSync();
      var client = await FirebaseHostingApiClient.create(
          serviceAccountKey: key, projectId: 'enspyrco');

      var currentVersion = await client.getCurrentVersion();
      var currentFiles = await client.listFiles(versionName: currentVersion);

      print(currentFiles);
    });

    test('saves files', () async {
      String key = File('test/key.string').readAsStringSync();
      var client = await FirebaseHostingApiClient.create(
          serviceAccountKey: key, projectId: 'enspyrco');

      var newVersion = await client.createNewVersion();

      // determine the hashes and bytes for the files to upload and put into a json map
      final upload = await UploadData.createFrom(path: 'test/data/coverage');

      var requiredHashes = await client.populateFiles(
        json: upload.json,
        versionName: newVersion,
      );

      await client.uploadFiles(
        requiredHashes: requiredHashes,
        pathForHash: upload.pathForHash,
        bytesForHash: upload.bytesForHash,
      );
    });
  });
}
