public class weatherNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, City__c, User__r.Email
        FROM Weather_City_Preference__c
        WHERE City__c != NULL
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<Weather_City_Preference__c> scope
  ) {
    List<Weather_City_Preference__c> cityPreferences = (List<Weather_City_Preference__c>) scope;
    Map<Id, List<weatherPlaying.WeatherWrapper>> cityPreferencesMap = new Map<Id, List<weatherPlaying.WeatherWrapper>>();

    for (Weather_City_Preference__c cityPreference : cityPreferences) {
      weatherPlaying.WeatherWrapper weather = weatherPlaying.getWeather(
        cityPreference.City__c
      );

      if (
        cityPreference.User__r == null ||
        String.isBlank(cityPreference.User__r.Email)
      ) {
        continue;
      }

      weather.city = cityPreference.City__c;

      weather.email = cityPreference.User__r.Email;

      if (weather.temperature > 30) {
        weather.comment = 'The temperature is too high';
      } else if (weather.temperature < 10) {
        weather.comment = 'The temperature is too low';
      } else {
        weather.comment = 'The temperature is just right';
      }

      if (cityPreferencesMap.containsKey(cityPreference.User__c)) {
        cityPreferencesMap.get(cityPreference.User__c).add(weather);
      } else {
        cityPreferencesMap.put(
          cityPreference.User__c,
          new List<weatherPlaying.WeatherWrapper>{ weather }
        );
      }
    }

    for (Id userId : cityPreferencesMap.keySet()) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

      if (cityPreferencesMap.get(userId).size() > 1) {
        email.setSubject('Weather Information for your prefered cities');
      } else {
        email.setSubject('Weather Information for your prefered city');
      }

      String[] toAddresses = new List<String>{
        cityPreferencesMap.get(userId)[0].email
      };

      email.setToAddresses(toAddresses);

      String body = '';

      for (
        weatherPlaying.WeatherWrapper weather : cityPreferencesMap.get(userId)
      ) {
        body +=
          'The temperature in ' +
          weather.city +
          ' is ' +
          String.valueOf(weather.temperature) +
          ' degrees Celsius.' +
          '\n\n' +
          weather.comment;
      }
      email.setPlainTextBody(body);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Finished');
  }
}
