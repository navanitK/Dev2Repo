public class MilestoneFutureAction 
{
    @future
	public static void setNextMilestoneCriteria (Id caseId)
    {
        Case abc = [
            Select id , casenumber, priority from Case where id = : caseId
        ];
        abc.priority = 'High';
        update abc;
    }
}