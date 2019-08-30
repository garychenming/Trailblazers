public with sharing class TrailblazersReptile implements Queueable, Database.AllowsCallouts {
    private string trailblazerId;
    
    public TrailblazersReptile(String trailblazerId) {
        this.trailblazerId = trailblazerId;
    }

    public void execute(QueueableContext qc) {
        try {
            Trailblazer__c trailblazer = [SELECT Id, ProfileUrl__c FROM TrailBlazer__c WHERE Id = :trailblazerId LIMIT 1];
            HttpRequest request = new HttpRequest();
            request.setEndpoint(trailblazer.ProfileUrl__c);
            request.setMethod('GET');
            HttpResponse response = (new Http()).send(request);
            String dataStr = response.getBody();
            String avatarUrl = dataStr.substringBetween('class="user-information__avatar-img" src="', '" alt="');
            String badgeCount = dataStr.substringBetween('data-test-badges-count>', '</div>');
            String points = dataStr.substringBetween('data-test-points-count>\n', '\n</div>').remove(',');
            String rank = dataStr.substringBetween('/assets/ranks/', '-');
            
            String badgesJSON = dataStr.substringBetween('<div data-react-class="BadgesPanel" data-react-props="', '"></div>').replace('&quot;', '"').replace('&#39;', '\'');
            Map<String, Object> badgesMap = (Map<String, Object>) JSON.deserializeUntyped(badgesJSON);
            badgesMap.remove('filters');
            badgesMap.remove('sharing');
            badgesJSON = JSON.serialize(badgesMap);

            trailblazer.AvatarUrl__c = avatarUrl;
            trailblazer.Badges__c = Integer.valueOf(badgeCount);
            trailblazer.Points__c = Integer.valueOf(points);
            trailblazer.Rank__c = rank;
            trailblazer.BadgesData__c = badgesJSON;

            update trailblazer;
        } catch(Exception ex) {
            insert new Log__c(ApexCodeName__c = 'TrailblazersReptile.execute', Data__c = JSON.serialize(ex));
        }
    }
}
