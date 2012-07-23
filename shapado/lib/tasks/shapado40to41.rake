task "upgrade40to41" => [:init, :"shapado40to41:levels", :"shapado40to41:update_versions", :"shapado40to41:activities", :"shapado40to41:stats", :"shapado3to4:regenerate_themes", :"assets:precompile"] do
end

namespace "shapado40to41" do
  task :levels => [:init] do
    Membership.all.each do |ms|
      print "."
      ms.level = LevelSystem.instance.level_for(ms.reputation)
      ms.save(:validate => false)
    end
  end

  task :update_versions => [:init] do
    ShapadoVersion.reload!
    legacy_public_id = ShapadoVersion.where(:token => 'legacy_public').first.id
    legacy_private_id = ShapadoVersion.where(:token => 'legacy_private').first.id
    Group.override({:private => false}, {:shapado_version_id => legacy_public_id})
    Group.override({:private => true}, {:shapado_version_id => legacy_private_id})
  end
  task :activities => [:init] do
    puts "Updating #{Activity.count} activities"

    Activity.all.each do |activity|
      next if activity.trackable_type == "Page" || activity.action == "destroy"

      question = activity.target

      if question.nil?
        question = activity.trackable rescue nil
      end

      if question.nil?
        print "I"
        next
      end

      if !question.kind_of?(Question)
        question = question.try(:question)
      end

      if !question.kind_of?(Question)
        puts "cannot handle activity: #{activity.id}"
        next
      end

      follower_ids = question.follower_ids+question.contributor_ids+[activity.user_id]
      activity.add_followers(*follower_ids)

      print "."
    end
  end

  task :stats => [:init] do
    Group.all.each do |g|
      if g.stats.blank?
        g.stats = GroupStat.new
        g.save
        print "."
      end
    end
  end
end
