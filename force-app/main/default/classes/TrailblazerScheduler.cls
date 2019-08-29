public with sharing class TrailblazerScheduler implements Schedulable {
    public TrailblazerScheduler() {

    }

    public void execute(SchedulableContext sc) {
        for(Trailblazer__c trailblazer : [select Id from Trailblazer__c where ProfileUrl__c != null]) {
            System.enqueueJob(new TrailblazersReptile(trailblazer.Id));
        }
    }
}
