class PopulateFilesResult {
  PopulateFilesResult(String uploadUrl, List<String> requiredHashes)
      : _uploadUrl = uploadUrl,
        _requiredHashes = requiredHashes;

  final String _uploadUrl;
  final List<String> _requiredHashes;

  String get uploadUrl => _uploadUrl;
  List<String> get requiredHashes => _requiredHashes;
}
