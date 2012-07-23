module QuestionsHelper
  def microblogging_message(question=nil)
    if question
      message = "#{h(question.title)}"
      message += " "
      message +=  escape_url(question_path(question, :only_path =>false))
      message
    else
      message = current_group.name
      message += " "
      message += escape_url(root_path(:only_path =>false))
    end
  end

  def linkedin_url(question)
    linkedin_share = question_path(question, :only_path =>false)
  end

  def share_url(question, service)
    url = ""
    case service
      when :twitter
        if logged_in? && current_user.twitter_token.present?
          url = twitter_share_question_url(question)
        else
          url = "http://twitter.com/?status=#{microblogging_message(question)}"
        end
      when :identica
        url = "http://identi.ca/notice/new?status_textarea=#{microblogging_message(question)}"
      when :shapado
        if question
          message = (question.title)+"&question[tags]=#{current_group.name},share&question[body]=#{h(question.body)}%20|%20[More...](#{h(question_path(question, :only_path =>false))})"
        else
          message = (current_group.name)+"&question[tags]=#{current_group.name},share&question[body]=#{current_group.name}%20|%20[More...](#{root_path(:only_path =>false)})"
        end
        url = "http://shapado.com/questions/new?question[title]="+message
      when :linkedin
        if question
          message = escape_url(question_url(question))+"&title=#{h(question.title)}&summary=#{h(question.body)}&source=#{current_group.name}"
        else
          message = escape_url(root_path(:only_path =>false))+"&title=#{current_group.name}&summary=#{current_group.description}&source=#{current_group.name}"
        end
        url = "http://linkedin.com/shareArticle?mini=true&url="+message
      when :think
        if question
          message = (question.title)+"&question[tags]=#{current_group.name},share&question[body]=#{h(question.body)}%20|%20[More...](#{h(question_path(question, :only_path =>false))})"
        else
          message = (current_group.name)+"&question[tags]=#{current_group.name},share&question[body]=#{current_group.name}%20|%20[More...](#{root_path(:only_path =>false)})"
        end
        url = "http://thnik.it/thoughts/new?question[title]="+message
      when :facebook
        if question
          if current_group.fb_button
            url = %@<iframe src="http://www.facebook.com/plugins/like.php?href=#{escape_url(question_path(question, :only_path =>false))}&amp;layout=button_count&amp;show_faces=true&amp;width=450&amp;action=like&amp;font&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:21px;" allowTransparency="true"></iframe>@
          else
            fb_url = "http://www.facebook.com/sharer.php?u=#{escape_url(question_path(question, :only_path =>false))}&t=#{question.title}"
            url = %@#{image_tag('/images/share/facebook_32.png', :class => 'microblogging')} #{link_to("facebook", fb_url, :rel=>"nofollow external")}@
          end
        else
          if current_group.fb_button
            url = %@<iframe src="http://www.facebook.com/plugins/like.php?href=#{escape_url(root_path(:only_path =>false))}&amp;layout=button_count&amp;show_faces=true&amp;width=450&amp;action=like&amp;font&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:21px;" allowTransparency="true"></iframe>@
          else
            fb_url = "http://www.facebook.com/sharer.php?u=#{escape_url(root_path(:only_path =>false))}&t=#{current_group.name}"
            url = %@#{image_tag('/images/share/facebook_32.png', :class => 'microblogging')} #{link_to("facebook", fb_url, :rel=>"nofollow external")}@
          end
        end
    end
    url.html_safe
  end

  protected
  def escape_url(url)
    URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end
