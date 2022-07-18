@isTest
private class UtilityObjectDataTest {

    private static TestDataObjectCreation td = new TestDataObjectCreation();    
    
    static testMethod void extractNewRecordsFromAllExisting() {
        // GIVEN a source list that contains only existing SObjects
        Account[] accs = new Account[]{};
        td.bulkInsert=true;
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test1'},null));
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test2'},null));
        insert accs;

        // WHEN extracting new records
        Test.startTest();
            Account[] newAccounts = (Account[]) UtilityObjectData.extractNewRecords(accs);
        Test.stopTest();

        // THEN source list will remain the same
        System.assertEquals(2, accs.size());

        // AND new records list will be empty
        System.assertEquals(0, newAccounts.size());
    }

    static testMethod void extractNewRecordsFromAllNew() {
        // GIVEN a source list that contains only new SObjects
        Account[] accs = new Account[]{};
        td.bulkInsert=true;
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test1'},null));
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test2'},null));

        // WHEN extracting new records
        Test.startTest();
            Account[] newAccounts = (Account[]) UtilityObjectData.extractNewRecords(accs);
        Test.stopTest();

        // THEN source list will now be empty
        System.assertEquals(0, accs.size());

        // AND new records list will contain the original records from the source
        System.assertEquals(2, newAccounts.size());
    }

    static testMethod void extractNewRecordsFromMixed() {
        // GIVEN a source list that contains a mixture of new and existing SObjects
        Account[] accs = new Account[]{};
        td.bulkInsert=true;
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test1'},null));
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test2'},null));
        insert accs;
        accs.add(td.insertAccount(new Map<String, Object>{'Name'=>'Test3'},null));
        
        // WHEN extracting new records
        Test.startTest();
            Account[] newAccounts = (Account[]) UtilityObjectData.extractNewRecords(accs);
        Test.stopTest();

        // THEN source list will now contain only the existing records
        System.assertEquals(2, accs.size());

        // AND new records list will contain only the new record
        System.assertEquals(1, newAccounts.size());
    }
    
}