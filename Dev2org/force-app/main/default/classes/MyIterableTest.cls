@IsTest
public class MyIterableTest {
	@IsTest
    private static void testIterableForLoop(){
        List<String> strings = new List<String> {'Hello','World'};
        MyIterable instance = new MyIterable (strings);
        for(String entry : strings){
            system.debug(entry);
        }
    }
}