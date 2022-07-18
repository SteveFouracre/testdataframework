global with sharing abstract class DML_Master {
    /*the functions below will check governor limits and if they are going to be exceeded it will automatically check if the user has allowed the records to be processed by batch
    if processByBatch=true and the context is currently not in a batch or a future the records will be processed by a batch and the user can specify a batch quantity
    otherwise if limits are not going to be exceeded and the user has passed Debugger__c[] to the function then the records will be processed by Saveresult
    any errors are returned by the function or if saveErrors=True then the erors are saved to the database directly from the function
    only merge and convertlead are not included but these are not used that often and merge will require at least 2 separate objects to be passed which doesnt really work for the structure of this framework
    */
    
    global enum dmlType {INSERT_OBJECT,INSERT_IMMEDIATE,UPDATE_OBJECT,UPSERT_OBJECT,DELETE_OBJECT,UNDELETE_OBJECT}
    
    public class DMLMasterException extends Exception { }
    @TestVisible private static Boolean testCheckPermissions = false;//used only for unit tests To Do:improve by using createStub
            
    global static integer defaultBatchQuantity = 100;
    global static GenericDMLResult[] masterErrorObject;
         
        @TestVisible
        static final String MSG_NO_PERMISSION    = 'Does not have permission to ';
        @TestVisible
        static final String MSG_LIMITS_EXCEEDED  = ' records not processed due to insufficient governor limits. Processing by batch was not allowed';
        @TestVisible
        static final String MSG_EXCEPTION        = 'Exception occurred: ';
        @TestVisible
        static final String MSG_BATCH_CONTEXT    = 'Processing by batch is not allowed as context is already in batch or future';
        @TestVisible
        static final String MSG_BATCH_FAILED     = 'Failed to create batch job';
    
    global static final String NO_CREATE_PERMISSION = 'Has No Create Permission';
    global static final String NO_UPDATE_PERMISSION = 'Has No Update Permission';
    global static final String NO_DELETE_PERMISSION = 'Has No Delete Permission';
    global static final String NO_UNDELETE_PERMISSION   = 'Has No UnDelete Permission';
    
    global static String defaultMsgCategory = 'Test Data';
         
    global static boolean insertObjects(sObject[] sObj){
        //this is the default insert function which allows the user to pass fewer arguments 
        masterErrorObject = new GenericDMLResult[]{};
        return genericDML(sObj, true, 200, masterErrorObject, true, dmlType.INSERT_OBJECT, 'Insert Objects', TriggerController.TRIGGER_NONE, null);
    }
    
    global static boolean insertObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String trigOff){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.INSERT_OBJECT, null, trigOff, null);
    }
    
    global static boolean insertObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.INSERT_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean insertBatchObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return processRecordsByBatch(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.INSERT_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean updateObjects(sObject[] sObj){
        masterErrorObject = new GenericDMLResult[]{};
        return genericDML(sObj, true, 200, masterErrorObject, true, dmlType.UPDATE_OBJECT, defaultMsgCategory, TriggerController.TRIGGER_NONE, null);
    }
    
    global static boolean updateObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String trigOff){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.UPDATE_OBJECT, null, trigOff, null);
    }
    
    global static boolean updateObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.UPDATE_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean updateBatchObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return processRecordsByBatch(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.UPDATE_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean deleteObjects(sObject[] sObj){
        masterErrorObject = new GenericDMLResult[]{};
        return genericDML(sObj, true, 200, masterErrorObject, true, dmlType.DELETE_OBJECT, defaultMsgCategory, TriggerController.TRIGGER_NONE, null);
    }
    
    global static boolean deleteObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String trigOff){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.DELETE_OBJECT, null, trigOff, null);
    }
    
    global static boolean deleteObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.DELETE_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean deleteBatchObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return processRecordsByBatch(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.DELETE_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean undeleteObjects(sObject[] sObj){
        masterErrorObject = new GenericDMLResult[]{};
        return genericDML(sObj, true, 200, masterErrorObject, true, dmlType.UNDELETE_OBJECT, defaultMsgCategory, TriggerController.TRIGGER_NONE, null);
    }
    
    global static boolean undeleteObjects(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, String msgCategory, String trigOff, String postProcessingClass){
        return genericDML(sObj, processByBatch, batchQuantity, errors, saveErrors, dmlType.UNDELETE_OBJECT, msgCategory, trigOff, postProcessingClass);
    }
    
    global static boolean genericDML(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, dmlType thisDMLType, String setErrorMsg, String trigOff, String postProcessingClass) {
        Boolean errorsOccurred = false;
        String errorMessage;
        try{
            if (thisDMLType == null || sObj == null) {
                throw new DMLMasterException('genericDML: Neither DmlType nor sObject[] can be NULL');
            }
    
            if (sObj.size() == 1 && sObj[0] == null) {
                throw new DMLMasterException('genericDML: sObject[] cannot contain NULL');
            }
    
            if (sObj.isEmpty()) {
                return true;
            }
            
            Schema.DescribeSObjectResult objDescribe = sObj[0].getSObjectType().getDescribe();
            
            UtilsMonitoring.setupMonitoring();
            
            // check we have permission
            if (!checkPermissionForDML(thisDMLType, objDescribe) || testCheckPermissions) {
                String msgPermis;
                if (thisDMLType == dmlType.INSERT_OBJECT) {
                    msgPermis = NO_CREATE_PERMISSION;
                }
                else if (thisDMLType == DmlType.UPDATE_OBJECT){
                    msgPermis = NO_UPDATE_PERMISSION;
                }
                else if (thisDMLType == DmlType.DELETE_OBJECT){
                    msgPermis = NO_DELETE_PERMISSION;
                }
                else if (thisDMLType == DmlType.UNDELETE_OBJECT){
                    msgPermis = NO_UNDELETE_PERMISSION;
                }
                errorMessage = msgPermis + thisDMLType + ' ' + objDescribe.getName();
                handleError(errorMessage, errors, saveErrors, setErrorMsg);
                errorsOccurred = true;
            }
            else {
                //permission allowed for dml
                Integer dmlCount = 1;
                Integer recordCount = sObj.size();
    
                // to support UPSERT, create separate lists for INSERT and UPDATE
                SObject[] sObjInsert;
                SObject[] sObjUpdate;
                if (thisDMLType == DmlType.INSERT_OBJECT) {
                    sObjInsert = sObj;
                }
                if (thisDMLType == DmlType.UPDATE_OBJECT) {
                    sObjUpdate = sObj;
                }
                if (thisDMLType == DmlType.UPSERT_OBJECT) {
                    sObjUpdate = new SObject[]{};
                    sObjUpdate.addAll(sObj);
                    sObjInsert = UtilityObjectData.extractNewRecords(sObjUpdate);
                    if (!sObjInsert.isEmpty() && !sObjUpdate.isEmpty()) {
                        dmlCount = 2;
                    }
                }
    
            
                Type convertedType = Type.forname(String.valueOf(sObj[0].getsObjectType()));
                if (trigOff != TriggerController.TRIGGER_NONE){
                    //this allows you to bypass triggers to improve efficiency of processing
                    if (trigOff == TriggerController.TRIGGER_ALL)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_NONE, true);
                    else if (trigOff == TriggerController.TRIGGER_INSERT)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_INSERT, true);
                    else if (trigOff == TriggerController.TRIGGER_UPDATE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_UPDATE, true);
                    else if (trigOff == TriggerController.TRIGGER_DELETE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_DELETE, true);
                    else if (trigOff == TriggerController.TRIGGER_UNDELETE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_UNDELETE, true);
                }
                
                //check number of total dml statements and number of records in dml
                if ((Limits.getDmlStatements() <= (Limits.getLimitDmlStatements() - dmlCount)) && (Limits.getDmlRows() + recordCount <= Limits.getLimitDmlRows())){
        
                    if (errors != null){
                        Database.saveresult[] res;
                        if (thisDMLType == dmlType.INSERT_OBJECT) {
                            //system.debug('##sch ' + objDescribe.isCreateable());                    
                            
                            res = Database.insert(sObjInsert,false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(res, sObjInsert);
                            errors.addAll(getDMLErrors(DML_Master.class,genericResults, saveErrors, setErrorMsg));
                        }
                        else if (thisDMLType == dmlType.UPDATE_OBJECT){
                            res = Database.update(sObjUpdate,false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(res, sObjUpdate);
                            errors.addAll(getDMLErrors(DML_Master.class,genericResults, saveErrors, setErrorMsg));
                        } 
                        else if (thisDMLType == dmlType.DELETE_OBJECT){
                            Database.Deleteresult[] desRes = Database.delete(sObj,false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(desRes, sObj);
                            errors.addAll(getDMLErrors(DML_Master.class, genericResults, saveErrors, setErrorMsg));
                        }
                        else if (thisDMLType == dmlType.UNDELETE_OBJECT){
                            Database.Undeleteresult[] undesRes = Database.undelete(sObj,false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(undesRes, sObj);
                            errors.addAll(getDMLErrors(DML_Master.class, genericResults, saveErrors, setErrorMsg));
                        }
                    }
                    else{
                        if ((thisDMLType == DmlType.INSERT_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjInsert.isEmpty())) {
                            insert sObjInsert;
                        }
                        if ((thisDMLType == DmlType.UPDATE_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjUpdate.isEmpty())) {
                            update sObjUpdate; 
                        }else if (thisDMLType == dmlType.DELETE_OBJECT){
                            delete sObj;
                        }else if (thisDMLType == dmlType.UNDELETE_OBJECT){
                            undelete sObj;
                        }
                    }
                }
                else{
                    //would break governor limits so try to do by batch
                    if (processByBatch){
                        processRecordsByBatch(sObj, processByBatch, batchQuantity, errors, saveErrors, thisDMLType, setErrorMsg, trigOff, postProcessingClass);
                    }
                    else{
                        UtilsMonitoring.buildMonitoringMessage(DML_Master.class, setErrorMsg, 'Could not save records. Processing by batch was not allowed.', null);
                    }
                }
                
                if (trigOff != TriggerController.TRIGGER_NONE){
                    //this resets trigger control
                    if (trigOff == TriggerController.TRIGGER_ALL)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_NONE, false);
                    else if (trigOff == TriggerController.TRIGGER_INSERT)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_INSERT, false);
                    else if (trigOff == TriggerController.TRIGGER_UPDATE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_UPDATE, false);
                    else if (trigOff == TriggerController.TRIGGER_DELETE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_DELETE, false);
                    else if (trigOff == TriggerController.TRIGGER_UNDELETE)
                        TriggerController.setTriggerControlValue(convertedType, TriggerController.TRIGGER_UNDELETE, false);
                }
                //End permission allowed for dml
            }
        }
        catch(Exception ex){
            errorMessage = MSG_EXCEPTION + ex.getMessage();
            handleError(errorMessage, errors, saveErrors, setErrorMsg);
            errorsOccurred = true;
        }
        finally {
            if (errorsOccurred && saveErrors) {
                UtilsMonitoring.saveMonitoringMessages(DML_Master.class);
            }
        }
        
        return !errorsOccurred;
    }
    
    global static Boolean processRecordsByBatch(sObject[] sObj, Boolean processByBatch, Integer batchQuantity, GenericDMLResult[] errors, Boolean saveErrors, dmlType thisDMLType, String setErrorMsg, String trigOff, String postProcessingClass) {
        Boolean errorsOccurred = false;
        if (!System.isBatch() && !System.isFuture()) {
            Database.executebatch(new batchProcessDMLConsolidation(thisDMLType, sObj, (errors == null), saveErrors, setErrorMsg, trigOff, postProcessingClass), (batchQuantity != null) ? batchQuantity : 200);
        }else{
            UtilsMonitoring.buildMonitoringMessage(DML_Master.class, setErrorMsg, 'Could not save records. Processing by batch was not allowed as context is already in batch or a future.', null);
            errorsOccurred = true;                  
        }
    
        return !errorsOccurred;
    }
    
       
    
        @TestVisible private static void handleError(String errorMessage, GenericDMLResult[] dmlResults, Boolean saveErrors, String messageType) {
            if (dmlResults != null) {
                dmlResults.add(new GenericDMLResult(false, null, null, errorMessage));
            }
            if (saveErrors) {
                UtilsMonitoring.buildMonitoringMessage(DML_Master.class, messageType, errorMessage, null);
            }
        }
    
        @TestVisible
        private static Boolean checkPermissionForDML(DmlType thisDMLType, Schema.DescribeSObjectResult objDescribe) {
            return (
                    (thisDMLType == DmlType.INSERT_OBJECT && objDescribe.isCreateable())
                            || (thisDMLType == DmlType.UPDATE_OBJECT && objDescribe.isUpdateable())
                            || (thisDMLType == DmlType.UPSERT_OBJECT && objDescribe.isCreateable() && objDescribe.isUpdateable())
                            || (thisDMLType == DmlType.DELETE_OBJECT && objDescribe.isDeletable())
                            || (thisDMLType == DmlType.UNDELETE_OBJECT && objDescribe.isUndeletable())
            );
        }
    
        @TestVisible private static GenericDMLResult[] getDMLErrors(System.Type cls, GenericDMLResult[] dmlResults, Boolean saveErrors, String messageType){
            GenericDMLResult[] dmlErrors = new GenericDMLResult[]{};
    
            // look through all the results for any failures
            for (GenericDMLResult result : dmlResults) {
                if (!result.success) {
                    // operation failed, so keep this result record
                    dmlErrors.add(result);
                    // report the errors
                    if (saveErrors) {
                        for (GenericDMLResult.GenericError err : result.errors) {
                            String errorMsg = err.statusCode + ': ' + err.message;
                            UtilsMonitoring.buildMonitoringMessage(cls, messageType, errorMsg, null);
                        }
                    }
                }
            }
    
            return dmlErrors;
        }
    
    }