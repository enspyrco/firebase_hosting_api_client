import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:firebase_hosting_api_client/src/utils/typedefs.dart';

/// UploadData
///
/// Constructors
/// - single public named constructor
/// - single static async [create] function
///
/// Inputs:
/// - parameter: dirPath
/// - env var: GITHUB_WORKSPACE
///   - of the form /home/runner/work/my-repo-name/my-repo-name (note: starting /, no closing /)
///

/// The data (files as bytes) and metadata (hashes, paths mapped to hashes, etc)
/// are calculated when the object is created and cannot be changed.
class UploadData {
  /// A single private constructor forces anyone wanting to create an [UploadData]
  /// to use the static function.
  UploadData._(
    Map<String, String> hashForPath,
    Map<String, Uint8List> bytesForHash,
    Map<String, String> pathForHash,
  )   : _uploadJson = {'files': hashForPath},
        _bytesFor = bytesForHash,
        _pathFor = pathForHash;

  /// A static function for asynchronously creating [UploadData] objects. All
  /// files in the given directory are used to calculate the metadata and
  /// package the file data ready for upload to Firebase Hosting.
  static Future<UploadData> createFrom(
      {required String workspaceDir, required String dirPath}) async {
    final dir = Directory(workspaceDir + '/' + dirPath + 'coverage');
    final hashForPath = <String, String>{};
    final bytesForHash = <String, Uint8List>{};
    final pathForHash = <String, String>{};

    final List<FileSystemEntity> entities =
        await dir.list(recursive: true).toList();

    print('Found ${entities.length} file system entities.');

    /// Calculate hashes and other metdata.
    var numFiles = 0;
    for (var entity in entities) {
      if (entity is File) {
        numFiles++;
        var bytes = entity.readAsBytesSync();
        var digest = sha256.convert(bytes);

        print(
            'hash: ${truncate(15, digest.toString())} from ...${entity.path} '); // .uri.pathSegments.last

        var fixedPath = entity.path.replaceFirst('.gz', '');
        hashForPath["/${entity.path.replaceFirst('.gz', '')}"] = '$digest';
        bytesForHash['$digest'] = bytes;
        pathForHash['$digest'] = entity.path;
        // .replaceFirst('$workspaceDir/', '')
        // ..replaceFirst('$workspaceDir/', '')
      }
    }

    print('Hashed $numFiles files.');

    // create an object from the data & metadata
    return UploadData._(hashForPath, bytesForHash, pathForHash);
  }

  /// Members.
  final JsonMap _uploadJson;
  final Map<String, Uint8List> _bytesFor;
  final Map<String, String> _pathFor;

  /// Getters.
  JsonMap get json => _uploadJson;
  Map<String, Uint8List> get bytesFor => _bytesFor;
  Map<String, String> get pathFor => _pathFor;

  /// Static utility functions
  static String truncate(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }
}
