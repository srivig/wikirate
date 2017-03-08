include_set Abstract::AwardBadges

event :award_source_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end

def badge_hierarchy
  Type::Source::BadgeHierarchy
end

def create_count
  Card.search type_id: SourceID,
              created_by: Auth.current_id,
              return: :count
end
