public class TriggerControlKeyValue {
    
    public system.type objectType;
    public string triggerType;
    
        public TriggerControlKeyValue(system.type thisObjectType, string thisTriggerType) {
            objectType = thisObjectType;
            triggerType = thisTriggerType; 
        }
    
        
        public boolean equals(object obj){
            
            if (obj instanceof TriggerControlKeyValue){
                TriggerControlKeyValue t = (TriggerControlKeyValue)obj;
                return (objectType.equals(t.objectType) && triggerType.equals(t.triggerType));
            }
            return false;
        }
        
        public integer hashCode(){
            return system.hashCode(objectType) * system.hashCode(triggerType);
        }
    
    }