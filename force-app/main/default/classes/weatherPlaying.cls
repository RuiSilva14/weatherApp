public with sharing class weatherPlaying {
  public class WeatherWrapper {
    @AuraEnabled
    public Decimal temperature;
    @AuraEnabled
    public String conditionText;
    @AuraEnabled
    public String icon;
    @AuraEnabled
    public String comment;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String email;
  }

  @AuraEnabled(cacheable=true)
  public static WeatherWrapper getWeather(String city) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:weatherCredentials/current.json?q=' +
      EncodingUtil.urlEncode(city, 'UTF-8')
    );
    req.setMethod('GET');
    Http http = new Http();
    HTTPResponse res = http.send(req);

    Map<String, Object> resBodyAsObj = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );

    WeatherWrapper weather = new WeatherWrapper();

    Map<String, Object> current = (Map<String, Object>) resBodyAsObj.get(
      'current'
    );

    weather.temperature = (Decimal) current.get('temp_c');

    Map<String, Object> condition = (Map<String, Object>) current.get(
      'condition'
    );

    weather.conditionText = (String) condition.get('text');
    weather.icon = (String) condition.get('icon');

    return weather;
  }

  @AuraEnabled(cacheable=true)
  public static List<Weather_Report__c> getWeatherReports(String accountId) {
    return [
      SELECT Id, Temperature__c, Weather_Condition__c, City__c, Date__c
      FROM Weather_Report__c
      WHERE Account__c = :accountId
      ORDER BY Date__c DESC
      LIMIT 5
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Weather_City_Preference__c> getUserCityPreferences() {
    Id userId = UserInfo.getUserId();
    try {
      List<Weather_City_Preference__c> cityPreferences = [
        SELECT Id, City__c, User__c
        FROM Weather_City_Preference__c
        WHERE User__c = :userId
      ];

      return cityPreferences;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Weather_City_Preference__c createCityPreference(String city) {
    try {
      Weather_City_Preference__c cityPreference = new Weather_City_Preference__c(
        City__c = city,
        User__c = UserInfo.getUserId()
      );

      insert cityPreference;

      return cityPreference;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void removeCity(String cityPreferenceId) {
    try {
      delete new Weather_City_Preference__c(Id = cityPreferenceId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
