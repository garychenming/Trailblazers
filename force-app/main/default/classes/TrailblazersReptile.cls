public with sharing class TrailblazersReptile implements Queueable, Database.AllowsCallouts {
    private string trailblazerId;
    
    public TrailblazersReptile(String trailblazerId) {
        this.trailblazerId = trailblazerId;
    }

    public void execute(QueueableContext qc) {
        try {
            Trailblazer__c trailblazer = [SELECT Id, ProfileUrl__c, TrailheadUserId__c FROM TrailBlazer__c WHERE Id = :trailblazerId LIMIT 1];
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://172.96.220.232:8081/getUserInfo?uid=' + trailblazer.TrailheadUserId__c);
            request.setMethod('GET');
            HttpResponse response = (new Http()).send(request);
            String dataStr = response.getBody();
            dataStr = dataStr.replaceAll('@odata.type', 'Type');
            Trailblazer t = (Trailblazer)JSON.deserialize(dataStr, Trailblazer.class);

            // String avatarUrl = dataStr.substringBetween('class="user-information__avatar-img" src="', '" alt="');
            Integer badgeCount = t.ProfileCounts[0].EarnedBadgeTotal;
            Integer points = t.ProfileCounts[0].EarnedPointTotal;
            String rank = t.ProfileCounts[0].RankLabel;

            // trailblazer.AvatarUrl__c = avatarUrl;
            trailblazer.Badges__c = badgeCount;
            trailblazer.Points__c = points;
            trailblazer.Rank__c = rank;
            // trailblazer.BadgesData__c = badgesJSON;

            update trailblazer;
        } catch(Exception ex) {
            insert new Log__c(ApexCodeName__c = 'TrailblazersReptile.execute', Data__c = ex.getMessage() + ex.getLineNumber());
        }
    }
}