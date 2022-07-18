tpublic with sharing class UtilsMonitoring {

public static Set< String > monitorSet;
public static Map<System.Type, Map<String, list<ErrorMessage>>> saveMonitoringMessagesMap;

    public class ErrorMessage{
        //populate other bespoke fields to hold these values. Monitoring now becomes very bespoke for your application
        
        public String msg;
        public Map<String, Object> additionalFields;
        
        public ErrorMessage(String aMsg, Map<String, Object> aKVals){
            if (aMsg != null) {
                this.msg = aMsg.abbreviate(255);
            }
            this.additionalFields = aKVals;
        }
    }
    
    public static Boolean getMonitoringCoverage(){
        //if this is set to true then monitoring will output everything held in saveMonitoringMessagesMap otherwise it will revert to whatever is set to the default 
        //section to monitor
        //eg UtilsMonitoring.saveMonitoringMesages(Account.class); will only save messgaes generated whereby the key is Account.class, but if the CS is True it will 
        //just save everything in saveMonitoringMessagesMap  
        
        return (((MonitoringCoverage__c.getOrgDefaults() != null) ? MonitoringCoverage__c.getOrgDefaults().value__c : false) || MonitoringCoverage__c.getInstance(UserInfo.getUserId()).value__c  || MonitoringCoverage__c.getInstance(UserInfo.getProfileId()).value__c) ;
    }
    
    public static void setupMonitoring(){
        //builds monitorSet of Monitoring that has been activated by the CS
        
        if (monitorSet == null || monitorSet.isempty()){
            Map<String, Monitoring__c> mon = Monitoring__c.getAll();

            if (!mon.isempty()){
                monitorSet = new Set< String >();
                for (Monitoring__c thisMon: mon.Values()){
                    if ((thisMon.Active__c && thisMon.Monitor_Datetime_From__c == null && thisMon.Monitor_Datetime_To__c == null) || (thisMon.Active__c && thisMon.Monitor_Datetime_From__c >= Datetime.Now() && thisMon.Monitor_Datetime_To__c <= Datetime.Now())){
                        if (thisMon.Name != null) monitorSet.add(thisMon.Name);
                    }
                }

                if (!monitorSet.isempty() && saveMonitoringMessagesMap == null){
                    saveMonitoringMessagesMap = new Map<System.Type, Map<String, list<ErrorMessage>>>();
                }
            }
        }       
    }
    
    public static void buildMonitoringMessage(System.Type objMonitor, String ref, String msg, Map<String, Object> otherFields) {        
    //if getMonitoringCoverage() return true all monitoring messages are saved, otherwise if the Type is Active specified in setupMonitoring()
     
        if (getMonitoringCoverage() || (monitorSet != null && !monitorSet.isempty() && monitorSet.contains(ref))){
            if (saveMonitoringMessagesMap != null && saveMonitoringMessagesMap.containskey(objMonitor)){
                if (saveMonitoringMessagesMap.get(objMonitor).containskey(ref))
                    (saveMonitoringMessagesMap.get(objMonitor).get(ref)).add(new ErrorMessage(msg, otherFields));
                else{
                    saveMonitoringMessagesMap.get(objMonitor).put(ref, new list<ErrorMessage>{new ErrorMessage(msg, otherFields)}); 
                }       
            }
            else{
                saveMonitoringMessagesMap.put(objMonitor, new Map<String, list<ErrorMessage>>{ref => new list<ErrorMessage>{new ErrorMessage(msg, otherFields)}}); 
            }
        }
    }
    
    public static void saveMonitoringMessages(System.Type objMonitor) {
        saveMonitoringMessages(objMonitor, false);
    }

    public static void saveMonitoringMessages() {
        saveMonitoringMessages(null, true);
    }

 @TestVisible
    private static void saveMonitoringMessages(System.Type objMonitor, Boolean saveAll) {

        // check the monitoring message map has messages
        if (saveMonitoringMessagesMap != null) {

            Integer parentCount = 0;
            Map<Integer, DebugParent__c> newDbgParents = new Map<Integer, DebugParent__c>();
            Map<Integer, Debugger__c[]> newDbgMessages = new Map<Integer, Debugger__c[]>();

            // for each source object type
            for (System.Type eachType : saveMonitoringMessagesMap.keySet()) {
                // check if we are to only save one source object type or all
                if (saveAll || objMonitor == eachType) {
                    // get the messages for the source object from the monitoring map
                    Map<String, List<ErrorMessage>> saveMsgs = saveMonitoringMessagesMap.get(eachType);

                    for (String ky : saveMsgs.keySet()) {

                        // create a Debug Parent for each item type
                        newDbgParents.put(parentCount, new DebugParent__c(Run_Category__c = ky));

                        for (ErrorMessage errMsg : saveMsgs.get(ky)) {

                            // create the Debug Message record
                            Debugger__c newDbg = new Debugger__c(msg__c = errMsg.msg);

                            // update additional field values
                            newDbg = (Debugger__c) UtilityObjectData.setSObjectFieldValues((Sobject)newDbg, errMsg.additionalFields);

                            // make a list of debug messages for this parent
                            if (!newDbgMessages.containsKey(parentCount)) {
                                newDbgMessages.put(parentCount, new Debugger__c[]{});
                            }

                            // add a new Debug Message record to the list
                            newDbgMessages.get(parentCount).add(newDbg);
                        }
                        ++parentCount;
                    }
                }
            }

            // save Debug Parent and Debug Message records
            insertDebugRecords(newDbgParents, newDbgMessages);

            // remove saved messages from the monitor message map
            if (saveAll) {
                saveMonitoringMessagesMap.clear();
            }
            else {
                saveMonitoringMessagesMap.remove(objMonitor);
            }
        }
    }

    
    @TestVisible private static Boolean insertDebugRecords( Map<Integer, DebugParent__c> newDbgParents,
            Map<Integer, Debugger__c[]> newDbgMessages ) {

        // Don't let any trappable errors cause the transaction to fail
        try {
            // check we have sufficient governor limits for number of DML statements
            if (Limits.getDmlStatements() <= (Limits.getLimitDmlStatements() -2)) {

                // save debug parent records
                if (!newDbgParents.isEmpty()) {

                    // check we have sufficient governor limits (number of DML records) for the Debug Parent records
                    if (newDbgParents.size() + Limits.getDmlRows() < Limits.getLimitDmlRows()) {

                        insert newDbgParents.values();

                        // create list of Debug Messages with link to correct Debug Parent record
                        Debugger__c[] totalDbgMessages = new Debugger__c[]{};
                        for (Integer thisParent : newDbgMessages.keySet()) {
                            DebugParent__c debugParent = newDbgParents.get(thisParent);
                            for (Debugger__c debugMessage : newDbgMessages.get(thisParent)) {
                                debugMessage.DebugParent__c = debugParent.Id;

                                // check we have sufficient governor limits (number of DML records) for the Debug Message
                                if (totalDbgMessages.size() + Limits.getDmlRows() < Limits.getLimitDmlRows()) {
                                    totalDbgMessages.add(debugMessage);
                                }
                            }
                        }
                        // save debug message records
                        if (!totalDbgMessages.isEmpty()) {
                            insert totalDbgMessages;
                        }
                    }
                }
                else{
                        // create list of Debug Messages NOT linking to Debug Parent records
                        Debugger__c[] totalDbgMessages = new Debugger__c[]{};
                        for (Integer thisParent : newDbgMessages.keySet()) {
                                // check we have sufficient governor limits (number of DML records) for the Debug Message
                                if (totalDbgMessages.size() + Limits.getDmlRows() < Limits.getLimitDmlRows()) {
                                    totalDbgMessages.addall(newDbgMessages.get(thisParent));
                                }
                        }
                        
                        // save debug message records
                        if (!totalDbgMessages.isEmpty()) {
                            insert totalDbgMessages;
                        }
                }
            }

            return true;

        }
        catch( Exception e ) {
            System.debug('### Unable to Insert Debug Records : '+e.getMessage());
            return false;
        }
    }

}