public abstract class TestDataReturn implements ITestData{
    
    public Map<System.Type, String> overrideJson = new Map<System.Type, String>();
    
    public Boolean bulkModeOn = false;
    
    public List<sObject> prepareSObject(String jsonStr, Map<String, Object> fldVals){

        if (!jsonStr.startsWith('[')) {
            jsonStr = '[' + jsonStr + ']';
        }

        //deserialize JSON
        List<SObject> sObj = (List<SObject>) System.JSON.deserialize(jsonStr, List<SObject>.class);

        //set other field values 
        if (fldVals != null) {
            for (SObject so : sObj) {
                so = UtilityObjectData.setObjData(so, fldVals);
            }
        }
        
        return sObj;
    }
}