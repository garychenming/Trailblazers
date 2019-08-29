public with sharing class TrailblazerTriggerHandler {
    public TrailblazerTriggerHandler() {

    }

    public static void triggerHandler() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            for (Trailblazer__c trailblazer : (List<Trailblazer__c>)Trigger.new) {
                Trailblazer__c oldTrailblazer = (Trailblazer__c) Trigger.oldMap.get(trailblazer.Id);

                if (oldTrailblazer.Badges__c != trailblazer.Badges__c || oldTrailblazer.Points__c != trailblazer.Points__c) {
                    notifiSlack(trailblazer, oldTrailblazer);
                }
            }
        }
    }

    private static void notifiSlack(Trailblazer__c trailblazer, Trailblazer__c oldTrailblazer) {
        Integer points = trailblazer.Points__c != null ? Integer.valueOf(trailblazer.Points__c) : 0;
        Integer badges = trailblazer.Badges__c != null ? Integer.valueOf(trailblazer.Badges__c) : 0;
        Integer badgeCount = Integer.valueOf(trailblazer.Badges__c - oldTrailblazer.Badges__c);
        Integer pointsCount = Integer.valueOf(trailblazer.Points__c - oldTrailblazer.Points__c);

        String message = JSON.serialize(new Map<String, String>{
            'text' => '>' + trailblazer.Name + '\n Total Points: `' + points + '`\n Total Badges: `' + badges + '`\n New Points: `' + pointsCount + '`\n New Badges: `' + badgeCount + '`'
        });
        SlackUtil.sendNotificationToSlack(message);
    }
}
