import { LightningElement, track, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getWeather from "@salesforce/apex/weatherPlaying.getWeather";

import BILLING_CITY from "@salesforce/schema/Account.BillingCity";

export default class WeatherPlaying extends LightningElement {
  @api recordId;
  city;

  @track weatherData = {
    temperature: 0,
    conditionText: "",
    icon: ""
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [BILLING_CITY]
  })
  WiredAccount({ error, data }) {
    if (data) {
      this.city = data.fields.BillingCity.value;

      getWeather({ city: this.city })
        .then((result) => {
          this.weatherData = result;
        })
        .catch((err) => {
          console.log("This is the error", err);
        });
    } else if (error) {
      console.log("This is the error", error);
    }
  }
}
