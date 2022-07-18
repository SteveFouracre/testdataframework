public with sharing class UtilityObjectData {
    private class TooManyBatchApexJobsException extends Exception{}
    
       public static Sobject setSObjectFieldValues(Sobject aobj, Map<String, Object> fldVals){
            if (aobj != null && fldVals != null) {
                for (String field : fldVals.keySet()) {
                    aobj.put(field, fldVals.get(field));
                }
            }
            
            return aobj;
       }
 
        public static SObject[] extractNewRecords(SObject[] sourceRecords) {
            //extracts records for insert only
            SObject[] newRecords = new SObject[]{};
            Integer i = 0;
            while (i < sourceRecords.size()) {
                if (sourceRecords[i].Id == null) {
                    newRecords.add(sourceRecords.remove(i));
                }
                else {
                    i++;
                }
            }
            return newRecords;
        }
}