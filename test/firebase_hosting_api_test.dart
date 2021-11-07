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

    test('saves a file', () async {
      String key = File('test/key.string').readAsStringSync();
      var client = await FirebaseHostingApiClient.create(
          serviceAccountKey: key, projectId: 'enspyrco');

      var newVersion = await client.createNewVersion();

      // determine the hashes and bytes for the files to upload and put into a json map
      final upload = await UploadData.createFrom(path: 'test/data/coverage');

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

    test('saves a different file', () async {
      String key = File('test/key.string').readAsStringSync();
      var client = await FirebaseHostingApiClient.create(
          serviceAccountKey: key, projectId: 'enspyrco');

      var newVersion = await client.createNewVersion();

      // determine the hashes and bytes for the files to upload and put into a json map
      final upload = await UploadData.createFrom(path: 'test/data/coverage2');

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

  test('saves a file without overwriting current files', () async {
    String key = File('test/key.string').readAsStringSync();
    var client = await FirebaseHostingApiClient.create(
        serviceAccountKey: key, projectId: 'enspyrco');

    /////////////////////////////////////////////////////////
    /// Put the server in a known state
    /////////////////////////////////////////////////////////

    var newVersion1 = await client.createNewVersion();

    // determine the hashes and bytes for the files to upload and put into a json map
    final upload1 = await UploadData.createFrom(path: 'test/data/coverage');

    var result1 = await client.populateFiles(
      json: upload1.json,
      versionName: newVersion1,
    );

    await client.uploadFiles(
      uploadUrl: result1.uploadUrl,
      requiredHashes: result1.requiredHashes,
      pathForHash: upload1.pathForHash,
      bytesForHash: upload1.bytesForHash,
    );

    await client.finalizeStatus(versionName: newVersion1);
    await client.release(versionName: newVersion1);

    /////////////////////////////////////////////////////////
    /// Attempt to upload a new file without overwriting
    /////////////////////////////////////////////////////////

    var newVersion2 = await client.createNewVersion();

    // determine the hashes and bytes for the files to upload and put into a json map
    final upload2 = await UploadData.createFrom(path: 'test/data/coverage2');

    // Add current file paths and hashes to upload data, if not from package.
    var currentVersion = await client.getCurrentVersion();
    var currentFiles = await client.listFiles(versionName: currentVersion);
    upload2.add(currentFiles);

    var result2 = await client.populateFiles(
      json: upload2.json,
      versionName: newVersion2,
    );

    await client.uploadFiles(
      uploadUrl: result2.uploadUrl,
      requiredHashes: result2.requiredHashes,
      pathForHash: upload2.pathForHash,
      bytesForHash: upload2.bytesForHash,
    );

    await client.finalizeStatus(versionName: newVersion2);
    await client.release(versionName: newVersion2);
  });
}
