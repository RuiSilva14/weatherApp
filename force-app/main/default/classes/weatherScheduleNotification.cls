public class weatherScheduleNotification implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new weatherNotificationBatch(), 50);
  }
}
