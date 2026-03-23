public class TestAuth 
{
    public static void getAcc()
    {
        HttpRequest req = new HttpRequest();
        String query='select+Id,Name+from+Account';
        req.setEndpoint('callout:RubberDucky/services/data/v49.0/query?q='+query);
        //https://nkdev1-dev-ed.lightning.force.com/
        //req.setEndpoint('https://nkdev1-dev-ed.lightning.force.com/services/data/v49.0?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        //while (resp.getStatusCode() == 302) {            req.setEndpoint(resp.getHeader('Location'));            resp = new Http().send(req);        }
        system.debug('Body:'+resp.getBody());
    }
    
     public static void customRest()
    {
        HttpRequest req = new HttpRequest();
        String query='select+Id,Name+from+Account';
        req.setEndpoint('callout:no_laumch/services/apexrest/DuaWebPage/getAcc');
        //https://nkdev1-dev-ed.lightning.force.com/
        //req.setEndpoint('https://nkdev1-dev-ed.lightning.force.com/services/data/v49.0?q='+query);
        ///services/data/v50.0/
        //req.setEndpoint('callout:RubberDucky/services/data/v50.0/');
        req.setMethod('GET');
        Http http = new Http();
        system.debug('123req'+ req);
        HTTPResponse resp = http.send(req);
        
        
        while (resp.getStatusCode() == 302) {
            req.setEndpoint(resp.getHeader('Location'));
            resp = new Http().send(req);
        }
        system.debug('Body:'+resp.getBody());
    }
    
    public static void testHeaders()
    {
        HttpRequest req = new HttpRequest();
String query='select+Id,Name+from+Account';
req.setEndpoint('callout:testapi/services/data/v49.0?q='+query);
req.setMethod('GET');
Http http = new Http();
HTTPResponse resp = http.send(req);
system.debug('Body:'+resp.getBody());
    }
}