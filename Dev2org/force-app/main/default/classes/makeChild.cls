public class makeChild {
    
    public static void makeBabies(){
        system.debug('### makeBabies');
        child__c newRec = new Child__c();
        newRec.name = system.now() + 'Faggot';
        
       	insert newRec;
    }

}