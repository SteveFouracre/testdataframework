public with sharing class TestDataJsonLibrary {

public class Standard{
             
    public Map<String, String> stdJsonMap = new Map<String, String>{};

    public Standard(){
        for (Test_Data__mdt m : [Select Label,Json__c From Test_Data__mdt]){
            stdJsonMap.put(m.Label, m.Json__c);
        }
    }
          
} 

}
