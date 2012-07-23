class AskForm
  attr_accessor :view_context

  def initialize(view_context)
    @view_context = view_context
  end

  # returns the action menu of the ask form
  # this menu contains links to edit, delete, follow up and more.
  def action_url
    view_context.url_for(question)
  end

  # returns a hidden text field with coordinates of the user
  # this is used to know where a user is located
  def geolocalization
    output = "".html_safe
    if question && question.position
      output << hidden_field_tag("question[position][lat]", question.position["lat"], :class => "lat_input")
      output << hidden_field_tag("question[position][long]", question.position["long"], :class => "long_input")
    end
    output
  end

  # returns the autocomplete tagging input widget
  def tags_input
    adding_field do |f|
      f.text_field :tags, :value => question.tags.join(", "), :class => "text_field autocomplete_for_tags"
    end
  end

  # returns the editor used to add description to a question
  def description_input
    adding_field do |f|
      view_context.render "questions/editor", :f => f
    end
  end

  # returns the file input needed to attach files to a question
  def attachments
    adding_field do |f|
      view_context.render "questions/attachment_editor", :f => f, :question => question
    end
  end

  # returns the text input required to add a title to a question
  def title_input
    adding_field do |f|
      f.text_field :title, :class => "text_area", :id => "question_title", :autocomplete => 'off'
    end
  end

  # return a select widget to pick the language of a question
  def language_input
    adding_field do |f|
      selected123 = @question.new? ? current_group.language : @question.language
      f.select :language, languages_options(known_languages(current_user, current_group)), {:selected => selected123}, {:class => "select"}
    end
  end

  # returns the submit button used to create a question
  def submit_button
    adding_field do |f|
      f.submit I18n.t("questions.index.ask_question", :default => :"layouts.application.ask_question"), :class => "ask_question"
    end
  end

  # returns the form to ask a question as an anonymous user
  def anonymous_form
    view_context.render "users/anonymous_form"
  end

  # returns a checkbox that allows users to decide whether their question can be improved by others
  def wiki_checkbox
    adding_field do |f|
      output = "".html_safe
      output << f.label(:wiki, "Wiki")
      output << f.check_box(:wiki)
      output
    end
  end

  # returns a checkbox to allow users to post their questions as anonymous users
  def anonymous_checkbox
    adding_field do |f|
      output = "".html_safe
      output << f.label(:anonymous, t("scaffold.post_as_anonymous"))
      output << f.check_box(:anonymous, {:class => "checkbox"}, true, false)
      output
    end
  end

  protected
  def adding_field(&block)
    output = ""
    view_context.form_for([question], :html => {:class => "add_question markdown"}) do |f|
      output = block.call(f)
    end

    output
  end

  def question
    view_context.instance_variable_get(:@question) || Question.new
  end

  def method_missing(name, *args, &block)
    view_context.send(name, *args, &block)
  end
end
