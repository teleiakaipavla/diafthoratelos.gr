class AnswerForm
  attr_accessor :view_context

  def initialize(view_context)
    @view_context = view_context
  end

  # returns the HTML form used to post an answer
  def render_default
    view_context.render "answers/form"
  end

  # returns the editor used to post an answer
  def editor
    adding_field do |f|
      view_context.render 'answers/editor', :f => f
    end
  end

  # returns the action menu of an answer
  # this menu contains links to edit, delete, follow up and more.
  def action_url
    view_context.url_for([question, answer])
  end

  # returns a text input to enter the user's name
  # this is used for users that are not signed in
  def author_name_input
    adding_user_field do |f|
      f.text_field :name
    end
  end

  # returns a text input to enter the user's email
  # this is used for users that are not signed in
  def author_email_input
    adding_user_field do |f|
      f.text_field :email
    end
  end

  # returns a text input to enter the user's website
  # this is used for users that are not signed in
  def author_website_input
    adding_user_field do |f|
      f.text_field :website
    end
  end

  # returns a recaptcha image
  # this is used for users that are not signed in
  def recaptcha
    if AppConfig.recaptcha["activate"]
      recaptcha_tag(:challenge, :width => 600, :rows => 5, :display => {:lang => I18n.locale}).html_safe
    end
  end

  # returns a checkbox that allows users to decide whether their answers can be improved by others
  def wiki_checkbox
    adding_field do |f|
      f.check_box :wiki, :class => "checkbox"
    end
  end

  # returns a checkbox to allow users to post their answers as anonymous users
  def anonymous_checkbox
    adding_field do |f|
      f.check_box :anonymous, :class => "checkbox"
    end
  end

  # returns true if current user is not signed in and if current group allows anonymous posts
  def if_anonymous
    !is_bot? && !user_signed_in? && current_group.enable_anonymous
  end

  # returns true if user is not signed in
  def if_not_logged_in
    !logged_in?
  end

  # returns true if user is signed in
  def if_logged_in
    logged_in?
  end

  protected
  def adding_field(&block)
    output = ""
    view_context.form_for([question, answer], :html => {:class => "add_answer markdown"}) do |f|
      output = block.call(f)
    end

    output
  end

  def adding_user_field(&block)
    output = ""
    view_context.fields_for :user do |f|
      output = block.call(f)
    end
    output
  end

  def question
    @question ||= view_context.instance_variable_get(:@question)
  end

  def answer
    @answer ||= view_context.instance_variable_get(:@answer) || Answer.new
  end

  def method_missing(name, *args, &block)
    view_context.send(name, *args, &block)
  end
end
