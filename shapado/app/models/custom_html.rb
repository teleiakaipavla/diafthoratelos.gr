# encoding: utf-8
class CustomHtml
  include Mongoid::Document

  embedded_in :group, :inverse_of => :custom_html

  identity :type => String
  field :top_bar, :type => String, :default => "[[faq|FAQ]]"

  field :question_prompt, :type => Hash, :default => {}
  field :question_help, :type => Hash, :default => {}

  field :head, :type => Hash, :default => {}
  field :footer, :type => Hash, :default => {}
  field :head_tag, :type => String
end
