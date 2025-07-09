public class weatherBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [SELECT Id, BillingCity FROM Account WHERE BillingCity != NULL]
    );
  }

  public void execute(Database.BatchableContext bc, List<Account> scope) {
    List<Account> accounts = (List<Account>) scope;
    List<Weather_Report__c> weatherReports = new List<Weather_Report__c>();
    for (Account acc : accounts) {
      weatherPlaying.WeatherWrapper weather = weatherPlaying.getWeather(
        acc.BillingCity
      );

      weatherReports.add(
        new Weather_Report__c(
          Account__c = acc.Id,
          Temperature__c = weather.temperature,
          Icon__c = weather.icon,
          Weather_Condition__c = weather.conditionText,
          City__c = acc.BillingCity,
          Date__c = Date.today()
        )
      );
    }
    insert weatherReports;
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Weather batch job completed');
  }
}
