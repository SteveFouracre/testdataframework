public with sharing class TriggerController {
    public static map<TriggerControlKeyValue, boolean> triggerDisableMap = new map<TriggerControlKeyValue, boolean>();
    public static map<TriggerControlKeyValue, boolean> triggerSuccessMap = new map<TriggerControlKeyValue, boolean>();

    public static final String TRIGGER_NONE = 'NONE';
    public static final String TRIGGER_ALL = 'ALL';
    public static final String TRIGGER_INSERT = 'INSERT';
    public static final String TRIGGER_UPDATE = 'UPDATE';
    public static final String TRIGGER_DELETE = 'DELETE';
    public static final String TRIGGER_UNDELETE = 'UNDELETE';

    public static Boolean getTriggerControlValue(System.Type objType, String triggerType){
        TriggerControlKeyValue tkv = new TriggerControlKeyValue(objType ,triggerType);
        Boolean triggerDisable = false;
        if (triggerDisableMap != null && triggerDisableMap.containskey(tkv))
            triggerDisable = triggerDisableMap.get(tkv);
            
        return triggerDisable; 
    }

    public static void setTriggerControlValue(System.Type objType, String triggerType, Boolean triggerDisable){
        TriggerControlKeyValue tkv = new TriggerControlKeyValue(objType ,triggerType);

        for (TriggerControlKeyValue eachtk : triggerDisableMap.keyset()){
            if (eachtk == tkv){
                tkv = eachtk;                   
                break;
            }
        }
        triggerDisableMap.put(tkv, triggerDisable);     
    }
    
    public static Boolean getTriggerSuccessValue(System.Type objType, String triggerType){
        TriggerControlKeyValue tkv = new TriggerControlKeyValue(objType ,triggerType);
        Boolean triggerSuccess = false;

        for (TriggerControlKeyValue eachtk : triggerSuccessMap.keyset()){
            if (eachtk == tkv){
                triggerSuccess = triggerSuccessMap.get(eachtk);
                break;
            }
        }
        
        return triggerSuccess; 
    }

    public static boolean globalTriggerControlSetting(){
        return (((Triggers_Off__c.getOrgDefaults() != null) ? Triggers_Off__c.getOrgDefaults().value__c : false) || Triggers_Off__c.getInstance(UserInfo.getUserId()).value__c  || Triggers_Off__c.getInstance(UserInfo.getProfileId()).value__c) ;
    }
    
    public static boolean globalTriggerPerObjectControlSetting(String obj){
        boolean success = true;
        try{        
            if (obj != null && obj != '') {
                if (!obj.endswith('__c')) obj += '__c';
                    boolean triggerPerObjectOrg = false;
                    if (Trigger_Per_Object__c.getOrgDefaults() != null && Trigger_Per_Object__c.getOrgDefaults().id != null){
                         if (Trigger_Per_Object__c.getOrgDefaults().get(obj) != null) triggerPerObjectOrg =  (boolean)Trigger_Per_Object__c.getOrgDefaults().get(obj);
                    }
                    
                    boolean triggerPerObjectUser = false;
                    if (Trigger_Per_Object__c.getInstance(UserInfo.getUserId()) != null  && Trigger_Per_Object__c.getInstance(UserInfo.getUserId()).id != null){
                        if (Trigger_Per_Object__c.getInstance(UserInfo.getUserId()).get(obj) != null) triggerPerObjectUser =  (boolean)Trigger_Per_Object__c.getInstance(UserInfo.getUserId()).get(obj);
                    }
                    
                    boolean triggerPerObjectProfile = false;
                    if (Trigger_Per_Object__c.getInstance(UserInfo.getProfileId()) != null && Trigger_Per_Object__c.getInstance(UserInfo.getProfileId()).id != null){
                        if (Trigger_Per_Object__c.getInstance(UserInfo.getProfileId()).get(obj) != null) triggerPerObjectProfile =  (boolean)Trigger_Per_Object__c.getInstance(UserInfo.getProfileId()).get(obj);
                    }
                    
                    success = (triggerPerObjectOrg || triggerPerObjectUser || triggerPerObjectProfile);
            }else 
                success = false;
        }
        catch(Exception ex){        
        }
        return success;
    }
    
}
