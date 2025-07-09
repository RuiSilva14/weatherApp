public class weatherBatchScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new weatherBatch(), 50);
  }
}
