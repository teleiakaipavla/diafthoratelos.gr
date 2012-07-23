class ThemeViewBase < Poirot::View
  def initialize(*args)
    super(*args)
  end

  # returns true if the current page is the front page '/'
  def if_front_page
    view_context.request.path == '/'
  end

  # returns true if current page is /questions
  def if_questions_page
    view_context.request.path == '/questions'
  end

  # returns a random question
  def random_question
    QuestionWrapper.new(current_group.questions.random, view_context)
  end

  # returns the HTML form box to ask new questions
  def add_ask_question_box
    view_context.render
  end

  # returns the list of recently used tags
  def foreach_recent_tag
    CollectionWrapper.new(current_group.tags.desc(:used_at).page(params[:tags_page]).per(25), TagWrapper, view_context)
  end

  # returns the list of recently rewarded badges
  def foreach_recent_badge
    CollectionWrapper.new(current_group.badges.desc(:created_at).page(params[:badges_page]).per(25), BadgeWrapper, view_context)
  end

  # returns the list of recent activities
  def foreach_recent_activity
    CollectionWrapper.new(current_group.activities.desc(:created_at).page(params[:activity_page]).per(25), ActivityWrapper, view_context)
  end

  # returns the widgets that are to be displayed on the header of each page
  def add_header_widgets
    view_context.render "shared/widgets", :context => 'mainlist', :position => 'header'
  end

  # returns the widgets that are to be displayed on the footer of each page
  def add_footer_widgets
    view_context.render "shared/widgets", :context => 'mainlist', :position => 'footer'
  end

  # returns the widgets that are to be displayed on the navigation bar of each page
  def add_navbar_widgets
    view_context.render "shared/widgets", :context => 'mainlist', :position => 'navbar'
  end

  # returns the widgets that are to be displayed on the side bar of each page
  def add_sidebar_widgets
    view_context.render "shared/widgets", :context => 'mainlist', :position => 'sidebar'
  end

  # returns the logo
  def logo_img
    view_context.image_tag view_context.logo_path(current_group)
  end

  # returns the link to the logo
  def logo_link
    link_to(logo_img, view_context.root_path)
  end

  # returns the search form
  def search_form
    %@<form accept-charset="UTF-8" action="#{view_context.search_index_path}" id="search" method="get">
      <div class='field'><input id="q" name="q" value="#{params[:q]}" type="text" class="textbox" /></div></form>@.html_safe
  end

  # returns the sign in drop down
  def signin_dropdown
    view_context.multiauth_dropdown("Sign In")
  end

  # returns link to the sign in page
  def signin_link
    view_context.link_to "Sign In", view_context.new_session_path(:user)
  end

  # returns link to the profile of the current user
  def current_user_link
    view_context.link_to current_user.name, current_user_url
  end

  # returns URL of the index of unanswered questions
  def unanswered_questions_url
    view_context.questions_url(:unanswered => 1)
  end

  # returns url of new question page
  def new_question_url
    view_context.new_question_url
  end

  # returns URL of the index of badges page
  def badges_url
    view_context.badges_url
  end

  # returns URL of the users index page
  def users_url
    view_context.users_url
  end

  # returns URL to the tags index page
  def tags_url
    view_context.tags_url
  end

  # returns URL of the questions index page /questions
  def questions_url
    view_context.questions_url
  end

  # returns URL of the questions feed
  def questions_feed_url
    view_context.questions_url(:format => "atom")
  end

  # returns URL of the hot question page
  def hot_questions_url
    view_context.questions_url(:tab => "hot")
  end

  # returns URL of the featured questions index page
  def featured_questions_url
    view_context.questions_url(:tab => "featured")
  end

  # returns URL of the current user page
  def current_user_url
    view_context.user_url(current_user)
  end

  # returns current shapado group
  def current_group
    view_context.current_group
  end

  # returns current theme
  def current_theme
    @current_theme ||= (current_group.current_theme || Theme.where(:is_default => true).first)
  end

  # returns true if current user is anonymous
  def if_anonymous
    !is_bot? && !view_context.user_signed_in? && current_group.enable_anonymous
  end

  # returns true if current user is not signed in
  def if_not_logged_in
    !view_context.user_signed_in?
  end

  # returns true if current user is signed in
  def if_logged_in
    view_context.user_signed_in?
  end

  # returns HTML form to ask new questions
  def ask_form
    AskForm.new(view_context)
  end
end
