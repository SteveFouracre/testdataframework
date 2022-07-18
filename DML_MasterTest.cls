@istest
public class DML_MasterTest {
private static String msgCategory = 'DML_Master Error Category';

private static testmethod void insertObjectsTest1()
    Test.startTest(); 
        DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 1);
    Test.stopTest();
}  

private static testmethod void insertObjectsTest2(){
    //THIS WILL FAIL BECAUSE BillingPostalCode IS NOT ALLOWED TO BE > 10 (Note: WHY 10 I DONT KNOW - WHICH LOOKS INCORRECT TO ME)
    Test.startTest();
        GenericDMLResult[] errors = new GenericDMLResult[]{};
        DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, errors, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 1);
        system.assert([Select id From Debugger__c].size() == 0);
        system.assert(errors.isempty() == true);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
}

private static testmethod void insertObjectsTest3(){
    Test.startTest();
        DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')});
        system.assert([Select id From Account].size() == 1);
    Test.stopTest();
} 

private static testmethod void insertObjectsTest4(){
    Test.startTest();
        GenericDMLResult[] errors = new GenericDMLResult[]{};
        DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, errors, true, msgCategory, TriggerController.TRIGGER_INSERT, null);
        system.assert([Select id From Account].size() == 1);
        system.assert([Select id From Debugger__c].size() == 0);
        system.assert(errors.isempty() == true);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
}

private static testmethod void updateObjectsTest1(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    acc.BillingPostalCode='SW123DF';
    Test.startTest();
        DML_Master.updateObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account where BillingPostalCode='SW123DF'].size() == 1);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void updateObjectsTest2(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        GenericDMLResult[] errors = new GenericDMLResult[]{};
        DML_Master.updateObjects(new Sobject[]{acc}, false, null, errors, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 1);
        system.assert([Select id From Debugger__c].size() == 0);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void updateObjectsTest3(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        GenericDMLResult[] errors = new GenericDMLResult[]{};
        DML_Master.updateObjects(new Sobject[]{acc}, false, null, errors, true, msgCategory, 'ALL', null);
        system.assert([Select id From Account ].size() == 1);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void updateObjectsTest4(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')});
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    acc.BillingPostalCode='SW123DF';
    Test.startTest();
        DML_Master.updateObjects(new Sobject[]{acc});
        system.assert([Select id From Account where BillingPostalCode='SW123DF'].size() == 1);
    Test.stopTest();
}

private static testmethod void deleteObjectsTest1(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 0);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void deleteObjectsTest2(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')});
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteObjects(new Sobject[]{acc});
        system.assert([Select id From Account].size() == 0);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void undeleteObjectsTest1(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 0);
        DML_Master.undeleteObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, 'ALL', null);
        system.assert([Select id From Account].size() == 1);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void undeleteObjectsTest2(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')});
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteObjects(new Sobject[]{acc});
        system.assert([Select id From Account].size() == 0);
        DML_Master.undeleteObjects(new Sobject[]{acc});
        system.assert([Select id From Account].size() == 1);
    Test.stopTest();
} 

//bypass triggers
private static testmethod void insertObjectsTest6(){
    Test.startTest(); 
        DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'None', null);
        system.assert([Select id From Account].size() == 1);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
}  

private static testmethod void updateObjectsTest5(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        GenericDMLResult[] errors = new GenericDMLResult[]{};
        DML_Master.updateObjects(new Sobject[]{acc}, false, null, errors, true, msgCategory, TriggerController.TRIGGER_UPDATE, null);
        system.assert([Select id From Account ].size() == 1);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_UPDATE) == false);
    Test.stopTest();
} 

private static testmethod void deleteObjectsTest3(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, TriggerController.TRIGGER_DELETE, null);
        system.assert([Select id From Account].size() == 0);
        system.assert(TriggerController.getTriggerSuccessValue(Account.class,TriggerController.TRIGGER_INSERT) == false);
    Test.stopTest();
} 

private static testmethod void processRecordsByBatchTest1(){
    Test.startTest();
        DML_Master.insertBatchObjects(new Sobject[]{new Account(name='Acc1')}, true, null, null, false, msgCategory, 'ALL', null);      
    Test.stopTest();
    system.assert([Select id From Account].size() == 1);
}  

private static testmethod void processRecordsByBatchTest2(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    acc.BillingPostalCode='SW123DF';
    Test.startTest();
        DML_Master.updateBatchObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, 'ALL', null);
    Test.stopTest();
    system.assert([Select id From Account where BillingPostalCode='SW123DF'].size() == 1);
}  

private static testmethod void processRecordsByBatchTest3(){
    DML_Master.insertObjects(new Sobject[]{new Account(name='Acc1')}, false, null, null, false, msgCategory, 'ALL', null);
    system.assert([Select id From Account].size() == 1);
    Account acc = [Select id, BillingPostalCode From Account limit 1];
    Test.startTest();
        DML_Master.deleteBatchObjects(new Sobject[]{acc}, false, null, null, false, msgCategory, TriggerController.TRIGGER_DELETE, null);      
    Test.stopTest();
    system.assert([Select id From Account].size() == 0);
} 


}