public with sharing class Trailblazer {
    public Trailblazer() {

    }

    public String Id { get; set; }
    public List<LearnedSkill> LearnedSkills { get; set; }
    public List<ProfileCount> ProfileCounts { get; set; }
    public List<EarnedAward> EarnedAwards { get; set; }

    public class LearnedSkill {
        public String Id { get; set; }
        public String Label { get; set; }
        public String Name { get; set; }
        public Integer UnitTotalPerSkill { get; set; }
    }

    public class ProfileCount {
        public String Id { get; set; }
        public String RankLabel { get; set; }
        public String RankImageUrl { get; set; }
        public String NextRankImageUrl { get; set; }
        public Integer EarnedPointTotal { get; set; }
        public Integer EarnedBadgeTotal { get; set; }
        public Integer CompletedTrailTotal { get; set; }
        public Integer PointTotalForNextRank { get; set; }
        public Integer BadgeTotalForNextRank { get; set; }
    }

    public class EarnedAward {
        public String Id { get; set; }
        public String LearningUrl { get; set; }
        public String AwardType { get; set; }
        public Award Award { get; set; }
    }

    public class Award {
        public String Type { get; set; }
        public String Id { get; set; }
        public String Name { get; set; }
        public String Label { get; set; }
        public String ImageUrl { get; set; }
        public String OrganizationId { get; set; }
    }
}
