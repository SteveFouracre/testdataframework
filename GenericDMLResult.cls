/**
 * @author  Steve Fouracre
 * A generic class to represent results of a single DML operation
 * This class is better used for recording errors from Database.SaveResult[], UpsertResult[], DeleteResult[] and UndeleteResult[]
 */
global class GenericDMLResult {

    global Id recordId;
    global SObject sObj;
    global Boolean success;//if the DML operation on this record was successful
    global GenericError[] errors;//list of errors for the DML operation

    global GenericDMLResult(Boolean isSuccess, Id recId, SObject recObject) {
        this.success = isSuccess;
        this.recordId = recId;
        this.sObj = recObject;
        this.errors = new GenericError[]{};
    }

    global GenericDMLResult(Boolean isSuccess, Id recId, SObject recObject, String errorMessage) {
        this(isSuccess, recId, recObject);
        if (errorMessage != null) {
            this.errors.add(new GenericError(errorMessage, null, null));
        }
    }

    global GenericDMLResult(Boolean dmlSuccess, Id dmlRecordId, SObject dmlObject, Database.Error[] dmlErrors) {
        this(dmlSuccess, dmlRecordId, dmlObject);
        if (dmlErrors != null) {
            for (Database.Error dmlError : dmlErrors) {
                this.errors.add(new GenericError(dmlError));
            }
        }
    }

    global class GenericError {
        global String message;
        global String fields;
        global StatusCode statusCode;

        global GenericError(String errorMessage, String errorFields, StatusCode errorCode) {
            this.message = errorMessage;
            this.fields = errorFields;
            this.statusCode = errorCode;
        }

        global GenericError(Database.Error dmlError) {
            this(dmlError.getMessage(), String.join(dmlError.getFields(),','), dmlError.getStatusCode());
        }
    }

    global static GenericDMLResult[] makeGeneric(Database.SaveResult[] results, SObject[] records) {
        //Converts SaveResult[] to GenericDmlResult[]
        //INSERT / UPDATE results as a SaveResult[]
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }
    
    global static GenericDMLResult[] makeGeneric(Database.UpsertResult[] results, SObject[] records) {
        //Converts UpsertResult[] to GenericDmlResult[]
        //UPSERT results as a UpsertResult[]
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

    global static GenericDMLResult[] makeGeneric(Database.DeleteResult[] results, SObject[] records) {
        //Converts DeleteResult[] to GenericDmlResult[]
        //DELETE results as a DeleteResult[]
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

    global static GenericDMLResult[] makeGeneric(Database.UndeleteResult[] results, SObject[] records) {
        //Converts UndeleteResult[] to GenericDmlResult[]
        //UNDELETE results as a UndeleteResult[]
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

}