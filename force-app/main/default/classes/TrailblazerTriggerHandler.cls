public with sharing class TrailblazerTriggerHandler {
    public TrailblazerTriggerHandler() {

    }

    public static void triggerHandler() {
        try {
            if (Trigger.isAfter && Trigger.isUpdate) {
                for (Trailblazer__c trailblazer : (List<Trailblazer__c>)Trigger.new) {
                    Trailblazer__c oldTrailblazer = (Trailblazer__c) Trigger.oldMap.get(trailblazer.Id);

                    if (oldTrailblazer.Badges__c != trailblazer.Badges__c || oldTrailblazer.Points__c != trailblazer.Points__c) {
                        notifiSlack(trailblazer, oldTrailblazer);
                    }
                }
            }

            if (Trigger.isBefore && Trigger.isUpdate) {
                for (Trailblazer__c trailblazer : (List<Trailblazer__c>)Trigger.new) {
                    Trailblazer__c oldTrailblazer = (Trailblazer__c) Trigger.oldMap.get(trailblazer.Id);

                    if (oldTrailblazer.Badges__c != trailblazer.Badges__c || oldTrailblazer.Points__c != trailblazer.Points__c) {
                        Integer points = trailblazer.Points__c != null ? Integer.valueOf(trailblazer.Points__c) : 0;
                        Integer oldPoints = oldTrailblazer.Points__c != null ? Integer.valueOf(oldTrailblazer.Points__c) : 0;

                        Integer newPoints = points - oldPoints;
                        trailblazer.NewPoints__c = trailblazer.NewPoints__c + newPoints;
                    }
                }
            }
        } catch(Exception ex) {
            insert new Log__c(ApexCodeName__c = 'TrailblazerTriggerHandler', Data__c = ex.getMessage() + ex.getLineNumber());
        }
    }

    private static void notifiSlack(Trailblazer__c trailblazer, Trailblazer__c oldTrailblazer) {
        Integer points = trailblazer.Points__c != null ? Integer.valueOf(trailblazer.Points__c) : 0;
        Integer oldPoints = oldTrailblazer.Points__c != null ? Integer.valueOf(oldTrailblazer.Points__c) : 0;
        Integer badges = trailblazer.Badges__c != null ? Integer.valueOf(trailblazer.Badges__c) : 0;
        Integer oldBadges = oldTrailblazer.Badges__c != null ? Integer.valueOf(oldTrailblazer.Badges__c) : 0;
        Integer badgeCount = Integer.valueOf(badges - oldBadges);
        Integer pointsCount = Integer.valueOf(points - oldPoints);

        notifiSlack(trailblazer.Name, points, badges, badgeCount, pointsCount, trailblazer.BadgesData__c, oldTrailblazer.BadgesData__c, trailblazer.AvatarUrl__c, trailblazer.ProfileUrl__c, trailblazer.NewPoints__c);
    }

    @future(callout=true)
    private static void notifiSlack(String name, Integer points, Integer badges, Integer badgeCount, Integer pointsCount, String badgesData, String oldBadgesData, String avatarUrl, String profileUrl, Decimal newPointsThisMonth
        ) {
        Map<String, Object> badgesMap = getBadgesMap(badgesData);
        Map<String, Object> oldBadgesMap = getBadgesMap(oldBadgesData);
        for (String title : oldBadgesMap.keySet()) {
            badgesMap.remove(title);
        }

        List<Map<String, Object>> attachments = new List<Map<String, Object>>();

        for (String title : badgesMap.keySet()) {
            String iconUrl = (String)((Map<String, Object>)badgesMap.get(title)).get('icon_url');
            String badgePath = (String)((Map<String, Object>)badgesMap.get(title)).get('path');
            attachments.add(new Map<String, Object>{
                'author_icon' => avatarUrl,
                'author_link' => profileUrl,
                'author_name' => name,
                'color' => '#36a64f',
                'fallback' => '',
                'fields' => '',
                // 'footer' => 'footer123213',
                // 'footer_icon' => 'https://trailhead-web.s3.amazonaws.com/uploads/users/5688092/photos/thumb_7661baf522e13a4e57cd9055938a3f86e6d3752ab20c48bd2967c8565f8909ba.png?updatedAt=20190828171128',
                'image_url' => iconUrl,
                'pretext' => name + ' got a new badge',
                // 'text' => 'text111',
                // 'thumb_url' => 'https://trailhead-web.s3.amazonaws.com/uploads/users/5180240/photos/thumb_MYXJ_20161115151755_fast.jpg?updatedAt=20190825193042',
                'title' => title,
                'title_link' => badgePath,
                'ts' => Datetime.now().getTime()
            });
        }

        String badgesStr = '*' + name + '* Total Points: `' + points + '` Total Badges: `' + badges + '` New Points: `' + pointsCount + '` New Badges: `' + badgeCount + '` New Earned Points This Month: `' + newPointsThisMonth + '`';
        String message = JSON.serialize(new Map<String, Object>{'text' => badgesStr,'attachments' => attachments});

        SlackUtil.sendNotificationToSlack(message);
    }

    private static Map<String, Object> getBadgesMap(String badgesData) {
        Map<String, Object> badgesMap = new Map<String, Object>();

        if (String.isNotBlank(badgesData)) {
            Map<String, Object> badgesMapping = (Map<String, Object>) JSON.deserializeUntyped(badgesData);

            for (Object badge : (List<Object>) badgesMapping.get('badges')) {
                badgesMap.put((String)((Map<String, Object>)badge).get('title'), badge);
            }
        }

        return badgesMap;
    }

    public class PointsData {
        public PointsData(Datetime gotTime, Integer points) {
            this.GotTime = gotTime;
            this.Points = points;
        }
        public Datetime GotTime { get; set; }
        public Integer Points { get; set; }
    }
}
