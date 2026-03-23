public class CountryCodeHelper {
    public static String getCountryCode(String country) {        
        Country_Code__mdt record = Country_Code__mdt.getInstance(country);
        return record.Country_Code__c;
    }
}