
List<Database.saveResult> sr = EventBus.publish(new List<basicEvent__e> {
    new basicEvent__e(),
    new basicEvent__e(data__c = 2)
});
System.debug(sr);
/*
List<Database.saveResult> sr2 = EventBus.publish(new List<basicEvent__e> {
    new basicEvent__e(data__c = 3),
    new basicEvent__e(data__c = 4)
});
 
basicEvent__e event = (basicEvent__e)basicEvent__e.sObjectType.newSObject(null, true);
event.data__c = 10;
System.debug('EventUuid: before ' + event.EventUuid);
Database.saveResult sr3 = EventBus.publish(event);
System.debug('EventUuid: after ' + event.EventUuid);

Database.saveResult sr4 = EventBus.publish(
    new basicEvent__e()
);
System.debug(sr4);
*/

///services/data/v56.0/sobjects/basicEvent__e/
// {
//    "Data__c" : "-5"
// }
///services/data/v56.0/sobjects/basicEvent__e/eventSchema
