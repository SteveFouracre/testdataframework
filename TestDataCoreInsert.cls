global abstract with sharing class TestDataCoreInsert extends TestDataReturn{
    public Map<System.Type, String> useThisJson = new Map<System.Type, String>();
    global Boolean bulkInsert = false;
    public Boolean saveErrors = false;
    public String debugMessageType = 'Test Data Framework';
    global Boolean allowBatch = false;
    public Integer batchSize = 200;
    global String deactivateTrigger = DML_Master.TRIGGER_ALL;
    global String postProcessorClass;
    
    global sObject insertAnyObject(String thisjson, Map<String, Object> fldVals, GenericDMLResult[] dbErrors, System.Type thisObjType){        
        // is a different json been set 
        if(this.useThisJson != null && this.useThisJson.containsKey(thisObjType))            
            thisjson = this.useThisJson.get(thisObjType);
         
        //pass json to object creator -  no DML
        sObject sobj = super.returnAnyObject(thisjson, fldVals)[0];
        
        // if bulkInsert is on then just return this 1 object which will be passed to Bulk Insert class to insert a number of objects
        //otherwise if False do insert object
        if(!bulkInsert)
            DML_Master.insertObjects(
                    new SObject[]{ sobj },
                    this.allowBatch,        // allow batch
                    this.batchSize,         // batch size
                    dbErrors,               // list to save errors into
                    this.saveErrors,        // save errors
                    this.debugMessageType,  // message type
                    this.deactivateTrigger,
                    this.postProcessorClass // batch post processor
            );
               
        return sobj;
    }

}
