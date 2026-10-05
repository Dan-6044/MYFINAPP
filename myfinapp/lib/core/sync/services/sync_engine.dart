abstract class SyncEngine {
  Future<void> sync();
  Future<void> processOutbox();
  Future<void> pullChanges();
  Future<void> pushChanges();
}
