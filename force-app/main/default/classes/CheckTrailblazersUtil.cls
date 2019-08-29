public with sharing class CheckTrailblazersUtil {
    public CheckTrailblazersUtil() {

    }

    public static void checkTrailblazers() {
        for (Trailblazer__c trailblazer : [SELECT Id FROM Trailblazer__c]) {
            TrailblazersReptile.refreshTrailblazer(trailblazer.Id);
        }
    }
}
