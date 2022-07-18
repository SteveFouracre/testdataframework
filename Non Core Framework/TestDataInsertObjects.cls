global virtual with sharing class TestDataInsertObjects extends TestDataCoreInsert{

    //An example function
    global xxx__c insertXXX(Map<String, Object> fldVals, GenericDMLResult[] errors){
        return (xxx__c) insertAnyObject(new TestDataJsonLibrary.Standard().stdJsonMap.get('xxx__c'), fldVals, errors, xxx__c.class);
    } 

}