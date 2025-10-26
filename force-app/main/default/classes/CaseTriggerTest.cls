@isTest
public class CaseTriggerTest {
    @isTest
    static void testCaseAutomation() {

        // Create a test case
        Case testCase = new Case(
            Subject = 'Projector not working',
            Category__c = 'IT Equipment',
            Issue_Severity__c = 'High',
            Estimated_Cost__c = 60000,
            Description = 'Projector in classroom 301 is not turning on.'
        );
        insert testCase;

        // Fetch updated record
        testCase = [SELECT Id, OwnerId, SLA_Deadline__c, Requires_Approval__c FROM Case WHERE Id = :testCase.Id];

        System.assertNotEquals(null, testCase.OwnerId, 'Owner should be auto-assigned.');
        System.assertNotEquals(null, testCase.SLA_Deadline__c, 'SLA Deadline should be set.');
        System.assertEquals(true, testCase.Requires_Approval__c, 'Approval flag should be true for costly issues.');
    }
}