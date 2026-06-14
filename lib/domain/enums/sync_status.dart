enum SyncStatus {
  synced('synced'),
  pending('pending'),
  failed('failed'),
  conflict('conflict');

  const SyncStatus(this.value);
  final String value;
}