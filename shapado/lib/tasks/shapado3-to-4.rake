## fixall0 and fixall1 can be ran in parallel, fixall2 must be ran at the end
desc "Fix all"

namespace "shapado3to4" do

  task :fixall => [:init, "shapado3to4:fixall0", "shapado3to4:fixall1", "shapado3to4:fixall2", "shapado3to4:fixall3", "shapado3to4:fixall4"] do
  end

  task :fixall0 => [:init, "shapado3to4:create_thumbnails"] do
  end

  task :fixall1 => [:init, "shapado3to4:questions", "shapado3to4:contributions", "shapado3to4:dates", "shapado3to4:openid", "shapado3to4:relocate", "shapado3to4:votes", "shapado3to4:counters", "shapado3to4:sync_counts", "shapado3to4:last_target_type"] do
  end

  task :fixall2 => [:init, "shapado3to4:fix_moved_comments_and_set_comment_count", "shapado3to4:comments", "shapado3to4:widgets", "shapado3to4:tags", "shapado3to4:update_answers_favorite"] do
  end

  task :fixall3 => [:init, "shapado3to4:groups", "shapado3to4:remove_retag_other_tag", "setup:create_reputation_constrains_modes", "shapado3to4:update_group_notification_config", "shapado3to4:set_follow_ids", "shapado3to4:set_friends_lists", "shapado3to4:fix_twitter_users", "shapado3to4:fix_facebook_users", "shapado3to4:set_invitations_perms", "shapado3to4:set_signup_type", "shapado3to4:versions", "shapado3to4:ads", "shapado3to4:wiki_booleans", "shapado3to4:themes", "shapado3to4:update_reputation_keys", "shapado3to4:votes_to_followers"]

  task :fixall4 => [:init, "shapado3to4:memberships", "shapado3to4:update_tag_followers_count"] do
  end

  task :clean_memberhips => [:init] do
    User.all.each do |u|
      count = 0
      u.memberships.each do |membership|
        if membership.last_activity_at.nil? && membership.reputation == 0.0
          membership.destroy
          count += 1
        end
      end
      if count > 0
        p "#{u.login}: #{count}"
      end
    end
  end

  task :memberships => [:init] do
    user_count= User.count
    user_count_i = 0
    memberships = []
    p "gathering memberships"
    User.all.each do |user|
      if user[:membership_list]
        count = user[:membership_list].count
        user.memberships.delete_all
        (user[:membership_list] || {}).each do |group_id, membership|
          if Group.find(group_id)
            membership["_id"] = BSON::ObjectId.new.to_s
            membership["group_id"] = group_id
            membership["user_id"] = user.id
            membership["joined_at"] ||= user.created_at
            memberships << membership
          end
        end
      end
      user_count_i+=1
      puts "#{user_count_i}/#{user_count}"
    end
    msc = memberships.size
    msi = 0
    p "creating memberships:"
    memberships.each do |m|
      Membership.create!(m)
      p "#{msi+=1}/#{msc}"
    end
    User.unset({}, {:membership_list => 1})
    p "done creating membership"
  end

  task :questions => [:init] do
    Question.all.each do |question|
      question.override(:_random => rand())
      question.override(:_random_times => 0.0)

      watchers = question.raw_attributes["watchers"]
      question.unset(:watchers => true)
      if watchers.kind_of?(Array)
        question.override(:follower_ids => watchers)
      end
    end
  end

  task :contributions => [:init] do
    Question.only(:user_id, :contributor_ids).all.each do |question|
      question.add_contributor(question.user) if question.user
      question.answers.only(:user_id).all.each do |answer|
        question.add_contributor(answer.user) if answer.user
      end
    end
  end

  task :dates => [:init] do
    %w[badges questions comments votes users announcements groups memberships pages reputation_events user_stats versions views_counts].each do |cname|
      coll = Mongoid.master.collection(cname)
      coll.find.each do |q|
        %w[activity_at last_target_date created_at updated_at birthday last_logged_at starts_at ends_at last_activity_at time date].each do |key|
          if q[key].is_a?(String)
            q[key] = Time.parse(q[key])
          end
        end
        coll.save(q)
      end
    end
  end

  task :openid => [:init] do
    User.all.each do |user|
      next if user.identity_url.blank?

      puts "Updating: #{user.login}"
      user.push_uniq(:auth_keys => "open_id_#{user[:identity_url]}")
      user.unset(:identity_url => 1)
    end
  end

  task :update_answers_favorite => [:init] do
    Mongoid.database.collection("favorites").remove
    answers = Mongoid.database.collection("answers")
    answers.update({ }, {"$set" => {"favorite_counts" => 0}})
  end

  task :sync_counts => [:init] do
    votes = Mongoid.database.collection("votes")
    comments = Mongoid.database.collection("comments")
    puts "updating comment's counts"
    comments.find.each do |c|
      print "."
      votes_average=0
      votes.find(:voteable_id =>  c["_id"]).each do |v|
        votes_average+=v["value"]
      end
      comments.update({:_id => c["id"]},
                      {"$set" => {"votes_count" => votes.find(:voteable_id =>  c["_id"]).count,
                                  "votes_average" => votes_average}})

      if c["flags"]
        comments.update({:_id => c["id"]}, {"$set" => {"flags_count" => c["flags"].size}})
      end
    end

    puts "updating questions's counts"
    Question.all.each do |q|
      print "."
      votes_average=0
      votes.find(:voteable_id =>  q.id).each do |v|
        votes_average+=v["value"]
      end
      q.override("flags_count" => q.flags.size, "votes_count" => q.votes.size, "votes_average" => votes_average)
    end
  end

  task :counters => :init do
    Question.all.each do |q|
      q.override(:close_requests_count => q.close_requests.size)
      q.override(:open_requests_count => q.open_requests.size)
    end
  end

  task :last_target_type => [:init] do
    puts "updating questions#last_target_type"
    Question.where({:last_target_type.ne => nil}).all.each do |q|
      print "."
      if(q.last_target_type != "Comment")
        last_target = q.last_target_type.constantize.find(q.last_target_id)
      else
        data = Mongoid.database.collection("comments").find_one(:_id => q.last_target_id)
        last_target = Comment.new(data)
      end

      if(last_target)
        if(last_target.respond_to?(:updated_at) && last_target.updated_at && last_target.updated_at.is_a?(String))
          last_target.updated_at = Time.parse(last_target.updated_at)
        end
        Question.update_last_target(q.id, last_target)
      end
    end
  end

  task :votes => [:init] do
    puts "updating votes"
    comments = Mongoid.database.collection("comments")
    comments.update({:votes => nil}, {"$set" => {"votes" =>  {}}}, :multi => true)
    questions = Mongoid.database.collection("questions")
    questions.update({:votes => nil}, {"$set" => {"votes" => {}}}, :multi => true)
    Group.all.each do |group|
      count = 0
      Mongoid.database.collection("votes").find({:group_id => group["_id"]}).each do |vote|
        vote.delete("group_id")
        id = vote.delete("voteable_id")
        klass = vote.delete("voteable_type")
        collection = comments
        if klass == "Question"
          collection = questions;
        end
        count += 1
        collection.update({:_id => id}, "$set" => {"votes.#{vote["user_id"]}" => vote["value"]})
      end
      if count > 0
        puts "Updated #{count} #{group["name"]} votes"
      end
    end
    Mongoid.database.collection("votes").drop
  end


  task :fix_moved_comments_and_set_comment_count => [:init] do
    comments = Mongoid.database.collection("comments")
    questions = Mongoid.database.collection("questions")
    users = Mongoid.database.collection("users")

    x = 0
    Mongoid.database.collection("comments").find(:_type => "Comment").each do |c|
      collection = comments
      if c["commentable_type"] == "Question"
        collection = questions;
      end
      parent = collection.find(:_id => c["commentable_id"]).first
      if parent && parent["group_id"] != c["group_id"]
        c["group_id"] = parent["group_id"]
        comments.update({ :_id => c["_id"]}, c)
        x += 1
      end

      # update user's comment count
      users.update({ :_id => c["user_id"]}, "$inc" => {"membership_list.#{c['group_id']}.comments_count" => 1})
    end
    p "#{x} moved comments had the wrong group_id"
  end

  task :comments => [:init] do
    puts "updating comments"
    comments = Mongoid.database.collection("comments")
    questions = Mongoid.database.collection("questions")
    questions.update({}, {"$set" => {:comments => []}})
    comments.update({}, {"$set" => {:comments => []}})

    Mongoid.database.collection("comments").find(:_type => "Comment").each do |comment|
      id = comment.delete("commentable_id")
      klass = comment.delete("commentable_type")
      collection = comments

      %w[created_at updated_at].each do |key|
        if comment[key].is_a?(String)
          comment[key] = Time.parse(comment[key])
        end
      end

      if klass == "Question"
        collection = questions;
      end

      comment.delete("comments")
      collection.update({:_id => id}, "$addToSet" => {:comments => comment})
      comments.remove({:_id => comment["_id"]})
    end
    begin
      Mongoid.database.collection("answers").drop
    ensure
      begin
        comments.rename("answers")
      rescue
        puts "comments collection doesn't exists"
      ensure
        Answer.override({}, {:_type => "Answer"})
      end
    end

    answers_coll = Mongoid.database.collection("answers")
    answers_coll.find().each do |answer|
      %w[created_at updated_at].each do |key|
        if answer[key].is_a?(String)
          answer[key] = Time.parse(answer[key])
        end
      end
      answers_coll.save(answer)
    end

    puts "updated comments"
  end

  task :groups => [:init] do
    Group.where({:language.in => [nil, '', 'none']}).all.each do |group|
      lang = group.description.to_s.language
      puts "Updating #{group.name} subdomain='#{group.subdomain}' detected as: #{lang}"

      group.language = (lang == :spanish) ? 'es' : 'en'
      group.languages = DEFAULT_USER_LANGUAGES

      if group.valid?
        group.save
      else
        puts "Invalid group: #{group.errors.full_messages}"
      end
    end
  end

  task :relocate => [:init] do
    doc = JSON.parse(File.read('data/countries.json'))
    i=0
    Question.override({:address => nil}, :address => {})
    Answer.override({:address => nil}, :address => {})
    User.override({:address => nil}, :address => {})
    doc.keys.each do |key|
      User.where({:country_name => key}).all.each do |u|
        p "#{u.login}: before: #{u.country_name}, after: #{doc[key]["address"]["country"]}"
        lat = Float(doc[key]["lat"])
        lon = Float(doc[key]["lon"])
        User.override({:_id => u.id},
                    {:position => {lat: lat, long: lon},
                      :address => doc[key]["address"] || {}})
#         FIXME
#         Comment.override({:user_id => u.id},
#                     {:position => GeoPosition.new(lat, lon),
#                       :address => doc[key]["address"]})
        Question.override({:user_id => u.id},
                    {:position => {lat: lat, long: lon},
                      :address => doc[key]["address"] || {}})
        Answer.override({:user_id => u.id},
                    {:position => {lat: lat, long: lon},
                      :address => doc[key]["address"] || {}})
      end
    end
  end

  task :widgets => [:init] do
    c=Group.count
    Group.unset({}, [:widgets, :question_widgets, :mainlist_widgets, :external_widgets])
    i=0
    Group.all.each do |g|
      g.reset_widgets!
      g.save(:validate => false)
      p "(#{i+=1}/#{c}) Updated widgets for group #{g.name}"
    end
  end

  task :update_group_notification_config => [:init] do
    puts "updating groups notification config"
    Group.all.each do |g|
      g.notification_opts = GroupNotificationConfig.new
      g.save
    end
    puts "done"
  end

  task :tags => [:init] do
    count = Question.count
    i = 0
    bad_count = 0
    Question.where(:tags => {"$ne" => [], "$ne" => nil}).all.each do |q|
      q.tags.each do |tag_name|
        existing_tag = Tag.where(:name => tag_name, :group_id => q.group_id).first
        if existing_tag
          existing_tag.inc(:count, 1)
        else
          tag = Tag.new(:name => tag_name)
          if q.group
            tag.group = q.group
            tag.user = q.group.owner
            tag.used_at = tag.created_at = tag.updated_at = q.group.questions.where(:created_at=>{:$ne=>nil}).order_by([:created_at, :asc]).first.created_at
            tag.save
          else
            bad_count += 0
          end
        end
      end
      p "#{i+=1}/#{count}"
    end
    p "Found #{bad_count} questions without"
  end

  task :remove_retag_other_tag => [:init] do
    Group.unset({}, "reputation_constrains.retag_others_tags" => 1 )
  end

  task :cleanup => [:init] do
    p "removing #{Question.where(:group_id => nil).destroy_all} orphan questions"
    p "removing #{Answer.where(:group_id => nil).destroy_all} orphan answers"
  end

  task :set_follow_ids => [:init] do
    p "setting nil following_ids to []"
    FriendList.override({:following_ids => nil}, {:following_ids => []})
    p "setting nil follower_ids to []"
    FriendList.override({:follower_ids => nil}, {:follower_ids => []})
    p "done"
  end

  task :set_friends_lists => [:init] do
    total = User.count
    i = 1
    p "updating #{total} users facebook friends list"
    User.all.each do |u|
      u.send(:initialize_fields)

      if u.external_friends_list.nil?
        u.send(:create_lists)
      end

      if u.read_list.nil?
        read_list = ReadList.create
        u.read_list = read_list
      end

      p "#{i}/#{total} #{u.login}"
      i += 1
    end
    p "done"
  end

  task :fix_twitter_users => [:init] do
    users = User.where({:twitter_token => {:$ne => nil}})
    users.each do |u|
      twitter_id = u.twitter_token.split('-').first
      p "fixing #{u.login} with twitter id #{twitter_id}"
      u["auth_keys"] = [] if u["auth_keys"].nil?
      u["auth_keys"] << "twitter_#{twitter_id}"
      u["auth_keys"].uniq!
      u["twitter_id"] = twitter_id
      u["user_info"] = { } if u["user_info"].nil?
      u["user_info"]["twitter"] = { "old" => 1}
      u.save(:validate => false)
    end
  end

  task :fix_facebook_users => [:init] do
    users = User.where({:facebook_id => {:$ne => nil}})
    users.each do |u|
      facebook_id = u.facebook_id
      p "fixing #{u.login} with facebook id #{facebook_id}"
      u["auth_keys"] = [] if u["auth_keys"].nil?
      u["auth_keys"] << "facebook_#{facebook_id}"
      u["auth_keys"].uniq!
      u["user_info"] = { } if u["user_info"].nil?
      u["user_info"]["facebook"] = { "old" => 1}
      u.save(:validate => false)
    end
  end

  task :create_thumbnails => [:init]  do
    Group.all.each do |g|
      begin
        puts "Creating thumbnails for #{g.name} #{g.id}"
        Jobs::Images.generate_group_thumbnails(g.id)
      rescue Mongo::GridFileNotFound => e
        puts "error getting #{g.name}'s logo"
      end
    end
  end


  task :set_invitations_perms => [:init] do
    p "setting invitations permissions on groups"
    p "only owners can invite people on private group by default"
    Group.override({:private => false}, {:invitations_perms => "owner"})
    p "anyone can invite people on private group by default"
    Group.override({:private => false}, {:invitations_perms => "user"})
    p "done"
  end

  task :set_signup_type => [:init] do
    p "setting signup type for groups"
    Group.override({:openid_only => true}, {:signup_type => "noemail"})
    Group.override({:openid_only => false}, {:signup_type => "all"})
    p "done"
  end

  task :versions => [:init] do
    Question.only(:versions, :versions_count).each do |question|
      next if question.versions.count > 0
      question.override({:versions_count => 0})
      (question[:versions]||[]).each do |version|
        version["created_at"] = version.delete("date")
        version["target"] = question

        question.version_klass.create!(version)
      end

      question.unset({:versions => true})
    end

    Answer.only(:versions, :versions_count).each do |post|
      next if post.versions_count.to_i > 0
      post.override({:versions_count => 0})
      (post[:versions]||[]).each do |version|
        version["created_at"] = version.delete("date")
        version["target"] = post

        post.version_klass.create!(version)
      end

      post.unset({:versions => true})
    end
  end

  task :ads => [:init]  do
    collection = Mongoid.database.collection("ads")
    counters = {}
    collection.find.each do |ad|
      group = Group.find(ad["group_id"])
      positions = {'context_panel' => "sidebar",
                   'header' => "header",
                   'footer' => "footer",
                   'content' => "navbar"}
      widget = nil
      if ad['_type'] == "Adsense"

        widget = AdsenseWidget.new(:settings =>{:client => ad['google_ad_client'],
                          :slot => ad['google_ad_slot'],
                          :width => ad['google_ad_width'],
                          :height => ad['google_ad_height']})
        widget_list = group.mainlist_widgets
        widget_list.send(:"#{positions[ad['position']]}") << widget
        widget.save
      end
    end
    collection.remove
  end

  task :wiki_booleans => [:init]  do
    Answer.override({:wiki=>"0"},{:wiki=>false})
    Answer.override({:wiki=>"1"},{:wiki=>true})
    Question.override({:wiki=>"0"},{:wiki=>false})
    Question.override({:wiki=>"1"},{:wiki=>true})
  end

  task :themes => [:init] do
    theme = Theme.where(:is_default => true).first
    if !theme
      theme = Theme.create_default
      theme.bg_image = File.open(Rails.root+"public/images/back-site.gif")
      Jobs::Themes.generate_stylesheet(theme.id)
      Group.override({}, :current_theme_id => theme.id)
    end

    Group.all.each do |g|
      if g.has_custom_css? && !g.custom_css.nil?
        begin
          custom_css = g.custom_css.read
          if !custom_css.blank?
            theme = Theme.create(:name => "#{g.name}'s theme", :custom_css => custom_css)
            begin
              Jobs::Themes.generate_stylesheet(theme.id)
            rescue
              p g.name
            end
          end
          g.delete_file("custom_css")
        rescue
          g.delete_file("custom_css")
          p "error"
        end
      end
    end
  end

  task :regenerate_themes => [:init] do
    Theme.all.each do |theme|
      begin
        Jobs::Themes.generate_stylesheet(theme.id)
      rescue
        p g.name
      end
    end
  end

  task :update_tag_followers_count => [:init] do
    Tag.override({}, {:followers_count => 0.0})
    Membership.all.each do |membership|
      Tag.increment({:name => {:$in => membership.preferred_tags||[]}, :group_id => membership.group.id}, {:followers_count => 1})
    end
  end

  task :update_reputation_keys => [:init] do
    Group.override({}, {"reputation_rewards.post_banned" => -200})
    Group.override({}, {"reputation_constrains.ask" => -100})
    Group.override({}, {"reputation_constrains.answer" => -300})
    ConstrainsConfig.override({}, {"content.ask" => -100})
    ConstrainsConfig.override({}, {"content.answer" => -300})
  end

  task :themes_files => [:init] do
    Theme.all.each do |f|
      f.stylesheet["content_type"] = "text/css"
      f.save
    end

    Theme.all.each do |f|
      f.has_js = false
      f.save
    end
  end

  task :fix_themes => [:init] do
    Theme.all.each do |theme|
      next if !theme[:button_bg_color]
      theme.override(:brand_color => theme[:button_bg_color])
    end
    Theme.unset({}, {:use_button_bg_color => true, :button_fg_color=> true, :button_bg_color=> true, :use_link_bg_color=> true, :link_bg_color=> true, :link_fg_color=> true, :view_fg_color=> true})
    Theme.all.each {|theme| Jobs::Themes.generate_stylesheet(theme.id)}
  end

  task :votes_to_followers => [:init] do
    count = Question.count
    i=1
    Question.all.each do |q|
      p "#{i}/#{count}"
      q.votes.keys.each do |u|
        q.add_follower(User.find(u))
      end
      i+=1
    end
  end

  task :set_default_theme => [:init] do
    Group.all.map do |g|
      if g.current_theme.nil?
        g.set_default_theme
      end
    end
  end

  task :create_about_widget => [:init] do
    Group.all.each do |g|
      w = AboutWidget.new
      g.mainlist_widgets.sidebar << w
      g.save
      g.reload
      g.mainlist_widgets.move_to(0, w.id, "sidebar")

    end
  end

  task :fix_languages => [:init] do
    User.where(:preferred_languages => {:$in => [/:/] }).each do |u|
      languages = u.preferred_languages.map do |l|
        if l =~ /.+:(.+)/
          $1
        else
          l
        end
      end
      u.preferred_languages = languages
      u.save
    end

    Group.where(:languages => {:$in => [/:/] }).each do |g|
      languages = g.languages.map do |l|
        if l =~ /.+:(.+)/
          $1
        else
          l
        end
      end
      g.languages = languages
      g.save
    end
  end

  task :add_follow_reward => [:init] do
    Group.all.each do |g|
      g.reputation_rewards = g.
        reputation_rewards.
        merge({ "question_receives_follow" => 2,
              "question_undo_follow" => -2})
      g.save
    end
  end

  task :fix_last_target => [:init] do
    total = Question.count
    i=0
    Question.all.each do |q|
      p "#{i+=1}/#{total}"
      last = q
      q.answers.each do |a|
        if last.updated_at < a.updated_at
          last = a
        end

        a.comments.each do |c|
          if last.updated_at < c.updated_at
            last = c
          end
        end
      end

      q.comments.each do |c|
        if last.updated_at < c.updated_at
          last = c
        end
      end
      Question.update_last_target(q.id, last)
    end
  end
end
