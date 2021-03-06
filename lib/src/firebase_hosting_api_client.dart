import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_hosting_api_client/src/models/populate_files_result.dart';
import 'package:firebase_hosting_api_client/src/models/version_file.dart';
import 'package:firebase_hosting_api_client/src/utils/constants.dart';
import 'package:firebase_hosting_api_client/src/utils/typedefs.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

/// Must be called in the right order
///
/// versionName takes the form: sites/SITE_ID/versions/VERSION_ID
///
/// You should call [closeClient] when you are done using the api.
///
class FirebaseHostingApiClient {
  final String _projectId;
  late final Uri _createNewVersionUri;
  late final Uri _getCurrentVersionUri;
  final bool _verboseLogging;

  final AuthClient _httpClient;

  FirebaseHostingApiClient._(
      AuthClient httpClient, String projectId, bool verboseLogging)
      : _httpClient = httpClient,
        _projectId = projectId,
        _verboseLogging = verboseLogging {
    _createNewVersionUri =
        Uri.https(host, '/v1beta1/sites/$_projectId/versions');
    _getCurrentVersionUri =
        Uri.https(host, '/v1beta1/sites/$_projectId/releases');
  }

  static Future<FirebaseHostingApiClient> create(
      {required String serviceAccountKey,
      required String projectId,
      bool verboseLogging = false}) async {
    var credentials =
        ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountKey));

    var client = await clientViaServiceAccount(
        credentials, ["https://www.googleapis.com/auth/firebase.hosting"]);

    return FirebaseHostingApiClient._(client, projectId, verboseLogging);
  }

  Future<String> getCurrentVersion() async {
    var response = await _httpClient.get(_getCurrentVersionUri,
        headers: {'Content-type': 'application/json'});

    var releases = jsonDecode(response.body)['releases'] as List;
    var current = releases.first;

    return current['version']['name'] as String;
  }

  /// returns the [versionName]
  Future<String> createNewVersion() async {
    var response = await _httpClient.post(_createNewVersionUri,
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          "config": {
            "headers": [
              {
                "glob": "**",
                "headers": {"Cache-Control": "max-age=1800"}
              }
            ]
          }
        }));

    _printIfVerbose(response.body);

    var versionName = jsonDecode(response.body)['name'];

    print('\nRetrieved version: $versionName');

    return versionName;
  }

  Future<List<VersionFile>> listFiles({required String versionName}) async {
    var listFilesUri = Uri.https(host, '/v1beta1/$versionName/files');
    print('\nListing files...');

    var listFilesResponse = await _httpClient
        .get(listFilesUri, headers: {'Content-type': 'application/json'});
    _printIfVerbose(listFilesResponse.body);

    var responseJson = jsonDecode(listFilesResponse.body);

    var filesJsonList = responseJson['files'] as JsonList;

    var versionFiles = filesJsonList
        .map<VersionFile>((element) => VersionFile.fromJson(element as JsonMap))
        .toList();

    return versionFiles;
  }

  /// Specify the list of files to deploy
  /// https://firebase.google.com/docs/hosting/api-deploy#specify-files
  ///
  /// Now that we have a new version identifier, we need to tell Firebase Hosting
  /// which files we want to eventually deploy in this new version.
  Future<PopulateFilesResult> populateFiles({
    required JsonMap json,
    required String versionName,
  }) async {
    var populateUri = Uri.https(host, '/v1beta1/$versionName:populateFiles');
    print('\nPopulating files...');

    print(json);

    var populateResponse = await _httpClient.post(
      populateUri,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode(json),
    );
    print(populateResponse.statusCode);
    print(populateResponse.body);

    _printIfVerbose(populateResponse.body);

    var responseJson = jsonDecode(populateResponse.body);

    var uploadUrl = responseJson['uploadUrl'];

    var requiredHashes = List<String>.from(
        (responseJson['uploadRequiredHashes'] ?? []) as List<dynamic>);

    print('Required hashes: $requiredHashes');

    return PopulateFilesResult(uploadUrl, requiredHashes);
  }

  Future<void> uploadFiles({
    required String uploadUrl,
    required List<String> requiredHashes,
    required Map<String, Uint8List> bytesForHash,
    required Map<String, String> pathForHash,
  }) async {
    int i = 1, total = requiredHashes.length;
    for (var hash in requiredHashes) {
      await _httpClient.post(Uri.parse('$uploadUrl/$hash'),
          headers: {'Content-Type': 'application/octet-stream'},
          body: bytesForHash[hash]);

      print('Uploaded ${i++}/$total - ${pathForHash[hash]}.');
    }
  }

  Future<void> finalizeStatus({required String versionName}) async {
    final statusUri =
        Uri.https(host, '/v1beta1/$versionName', {'update_mask': 'status'});
    print(statusUri);

    var statusResponse = await _httpClient.patch(statusUri,
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({'status': 'FINALIZED'}));
    print('\nFINALIZED');
    _printIfVerbose(statusResponse.body);
  }

  Future<void> release({required String versionName}) async {
    final releaseUri = Uri.https(host, '/v1beta1/sites/$_projectId/releases',
        {'versionName': versionName});
    var releaseResponse = await _httpClient.post(releaseUri);

    print('\nRELEASED');
    _printIfVerbose(releaseResponse.body);
  }

  void close() => _httpClient.close();

  void _printIfVerbose(Object object) {
    if (_verboseLogging) print(object);
  }
}
