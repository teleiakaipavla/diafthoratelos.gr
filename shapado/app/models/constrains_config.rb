
class ConstrainsConfig
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidExt::Slugizer

  CONSTRAINS = %w[vote_up vote_down flag post_images comment delete_own_comments
                  create_new_tags post_whithout_limits edit_wiki_post
                  remove_advertising vote_to_open_own_question vote_to_close_own_question
                  retag_others_questions delete_comments_on_own_questions
                  edit_others_posts view_offensive_counts vote_to_close_any_question
                  vote_to_open_any_question delete_closed_questions moderate ask answer]

  identity :type => String
  field :content, :type => Hash, :default => {}
  field :name, :type => String
  slug_key :name, :unique => true

  referenced_in :user
  referenced_in :group

  validates_uniqueness_of   :name
  validates_presence_of     :name

  def check_reputation_configs
    if self.content_changed?
      self.content.each do |k,v|
        self.content[k] = v.to_i
        if !CONSTRAINS.include?(k)
          self.content.add(:content, "Invalid key")
          return false
        end
      end
    end
  end
end

