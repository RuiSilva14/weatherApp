import { LightningElement, api, wire } from "lwc";
import getWeatherReports from "@salesforce/apex/weatherPlaying.getWeatherReports";
import getUserCityPreferences from "@salesforce/apex/weatherPlaying.getUserCityPreferences";

import removeCity from "@salesforce/apex/weatherPlaying.removeCity";
import createCityPreference from "@salesforce/apex/weatherPlaying.createCityPreference";

export default class WeatherPlaying extends LightningElement {
  @api recordId;
  weatherReports;
  cityPreferences;
  newCity;

  columns = [
    { label: "City", fieldName: "City__c", type: "text" },
    {
      label: "Temperature",
      fieldName: "Temperature__c",
      type: "number"
    },
    {
      label: "Weather Condition",
      fieldName: "Weather_Condition__c",
      type: "text"
    },
    { label: "Date", fieldName: "Date__c", type: "date" }
  ];

  @wire(getUserCityPreferences)
  cityPreferencesList({ error, data }) {
    if (data) {
      this.cityPreferences = data;
    } else if (error) {
      console.log("This is the error", error);
    }
  }

  @wire(getWeatherReports, { accountId: "$recordId" })
  weatherReportsList({ error, data }) {
    if (data) {
      this.weatherReports = data;
    } else if (error) {
      console.log("This is the error", error);
    }
  }

  removeCityPreference(event) {
    const id = event.target.dataset.id;
    removeCity({ cityPreferenceId: id })
      .then(() => {
        this.cityPreferences = this.cityPreferences.filter(
          (city) => city.Id !== id
        );
      })
      .catch((error) => {
        console.log("This is the error", error);
      });
  }

  handleCityChange(event) {
    this.newCity = event.target.value;
  }

  addCityPreference() {
    createCityPreference({ city: this.newCity })
      .then((data) => {
        this.cityPreferences = [...this.cityPreferences, data];
        this.newCity = "";
      })
      .catch((error) => {
        console.log("This is the error", error);
      });
  }
}
