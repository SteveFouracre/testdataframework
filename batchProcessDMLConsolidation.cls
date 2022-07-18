global class batchProcessDMLConsolidation implements Database.Batchable<sObject>, Database.Stateful {
    global Sobject[] allSobj;
    global DML_Master.DmlType dml_Type;
    global GenericDMLResult[] dmlErrors;
    global Boolean allOrNone;
    global Boolean saveErrors;
    global String messageType;
    global String trigOff;
    global String postProcessingClass;
    global final String errorCatyegory = 'Batch Processing';
    global set<Id> tdcIDSet;
    global Sobject[] passRecs;
        
    
    global batchProcessDMLConsolidation(DML_Master.DmlType operation, SObject[] records, Boolean allOrNone, Boolean saveErrors, String messageType, String trigOff, String postProcessingClass) {
        setup(operation, records, allOrNone, saveErrors, messageType, trigOff, postProcessingClass);
    }

    global batchProcessDMLConsolidation(DML_Master.DmlType operation, SObject[] records, Boolean allOrNone, Boolean saveErrors, String messageType, String trigOff, Sobject[] passRecs, String postProcessingClass) {
        setup(operation, records, allOrNone, saveErrors, messageType, trigOff, postProcessingClass);
        this.passRecs = passRecs;
    }

    private void setup(DML_Master.DmlType operation, SObject[] records, Boolean allOrNone, Boolean saveErrors, String messageType, String trigOff, String postProcessingClass){
        this.allSobj = records;
        this.dml_Type = operation;
        this.allOrNone = allOrNone;
        this.saveErrors = saveErrors;
        this.dmlErrors = new GenericDMLResult[]{};
        this.messageType = messageType;
        this.trigOff = trigOff;
        this.postProcessingClass = postProcessingClass;
        
        //Add logic for postProcessingClass 
    }
    
    global list<Sobject> start(Database.BatchableContext BC) {        
        return allSobj;
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> sobj) {
        try {
            GenericDMLResult[] batchResults;
            if (!this.allOrNone) {
                batchResults = new GenericDMLResult[]{};
            }
            
            //call genericDML to run the dml because it could be another function call this batch not necessarily DML_Master so permissions etc may not have been checked
            Boolean success = DML_Master.genericDML(sobj, false, 0, batchResults, this.saveErrors, this.dml_Type, this.messageType, trigOff, null);
            if (success){
            	//Add logic for postProcessingClass 
            }
            if (batchResults != null) {
                this.dmlErrors.addAll(batchResults);
            }
        }
        catch (Exception ex) {
            UtilErrors.addErrorMsgsAndSave('batchProcessDMLConsolidation','execute',null, null, 'Error:'+ ex.getMessage() + ' Line=' + ex.getLineNumber(), null, 'execute', true);
        }
            
    }

    global void finish(Database.BatchableContext BC) {
        if (postProcessingClass != null && String.isNotBlank(postProcessingClass)) {
            BatchDMLPostProcessorInterface postProcessor = (BatchDMLPostProcessorInterface)Type.forName(postProcessingClass).newInstance();
            
            postProcessor.performPostProcessing(this);
        }
    }
    
}