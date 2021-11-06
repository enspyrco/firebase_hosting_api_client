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

      // Add current file paths and hashes to upload data, if not from package.
      var currentVersion = await client.getCurrentVersion();
      var currentFiles = await client.listFiles(versionName: currentVersion);
      for (var file in currentFiles) {
        print('added file with path: ${file.path}');
        upload.json[file.path] = file.hash;
      }

      var result = await client.populateFiles(
        json: upload.json,
        versionName: newVersion,
      );

      await client.uploadFiles(
        uploadUrl: result.uploadUrl,
        requiredHashes: result.requiredHashes,
        pathForHash: upload.pathForHash,
        bytesForHash: upload.bytesForHash,
      );

      await client.finalizeStatus(versionName: newVersion);
      await client.release(versionName: newVersion);
    });
  });
}
