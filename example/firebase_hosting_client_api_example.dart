import 'package:firebase_hosting_api_client/client.dart';
import 'package:firebase_hosting_api_client/src/utils/typedefs.dart';

void main() async {
  var client = await FirebaseHostingApiClient.create(
      serviceAccountKey: 'get a key from gcp console', projectId: 'test');

  // retrieve current files
  // var currentVersion = await client.getCurrentVersion();
  // var currentFiles = await client.listFiles(versionName: currentVersion);

  var newVersion = await client.createNewVersion();

  // determine the hashes and bytes for the files to upload and put into a json map
  JsonMap uploadJson = {'files': {}};

  var requiredHashes = await client.populateFiles(
    json: uploadJson,
    versionName: newVersion,
  );

  // await client.uploadFiles(
  //   requiredHashes: requiredHashes,
  //   pathForHash: ,
  //   bytesForHash: ,
  // );

  await client.finalizeStatus(versionName: newVersion);
  await client.release(versionName: newVersion);

  client.close();
}
