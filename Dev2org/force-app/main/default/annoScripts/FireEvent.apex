
List<Database.saveResult> sr = EventBus.publish(new List<basicEvent__e> {
    new basicEvent__e(data__c = 1),
    new basicEvent__e(data__c = 2)
});
System.debug(sr);

List<Database.saveResult> sr2 = EventBus.publish(new List<basicEvent__e> {
    new basicEvent__e(data__c = 3),
    new basicEvent__e(data__c = 4)
});

///services/data/v56.0/sobjects/basicEvent__e/
// {
//    "Data__c" : "-5"
// }
