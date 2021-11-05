/// The current status of the files being added to a version.
///
/// https://firebase.google.com/docs/reference/hosting/rest/v1beta1/sites.versions.files/list#status
enum StatusEnum {
  // The default status; should not be intentionally used.
  unspecified,

  // The file has been included in the version and is expected to be uploaded in the near future.
  expected,

  // The file has already been uploaded to Firebase Hosting.
  active,

  // Not in the Firebase enum - used when none of the above are found.
  unkown,
}
