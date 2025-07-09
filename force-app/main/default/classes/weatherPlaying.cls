public with sharing class weatherPlaying {
  public class WeatherWrapper {
    @AuraEnabled
    public Decimal temperature;
    @AuraEnabled
    public String conditionText;
    @AuraEnabled
    public String icon;
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
}
