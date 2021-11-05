import 'package:firebase_hosting_api_client/src/models/status_enum.dart';
import 'package:firebase_hosting_api_client/src/utils/typedefs.dart';

/// A static content file that is part of a version.
///
/// https://firebase.google.com/docs/reference/hosting/rest/v1beta1/sites.versions.files/list#versionfile
class VersionFile {
  VersionFile._(
      {required String path, required String hash, required StatusEnum status})
      : _path = path,
        _hash = hash,
        _status = status;

  String get path => _path;
  String get hash => _hash;
  StatusEnum get status => _status;

  final String _path;
  final String _hash;
  final StatusEnum _status;

  static VersionFile fromJson(JsonMap json) => VersionFile._(
      path: json['path'] as String,
      hash: json['hash'] as String,
      status: _enumFrom(json['status'] as String));

  static _enumFrom(String str) {
    switch (str) {
      case 'ACTIVE':
        return StatusEnum.active;
      case 'EXPECTED':
        return StatusEnum.expected;
      case 'STATUS_UNSPECIFIED':
        return StatusEnum.unspecified;
      default:
        return StatusEnum.unkown;
    }
  }

  @override
  String toString() {
    return 'path: $_path, hash: $_hash, status: $_status';
  }
}
