class FacebookController < ApplicationController
  layout "facebook"

  subtabs :index => [[:newest, [:created_at, Mongo::DESCENDING]],
                     [:hot, [[:hotness, Mongo::DESCENDING], [:views_count, Mongo::DESCENDING]]],
                     [:votes, [:votes_average, Mongo::DESCENDING]],
                     [:activity, [:activity_at, :desc]], [:expert, [:created_at, Mongo::DESCENDING]]],
          :unanswered => [[:newest, [:created_at, Mongo::DESCENDING]], [:votes, [:votes_average, Mongo::DESCENDING]], [:mytags, [:created_at, Mongo::DESCENDING]]],
          :show => [[:votes, [:votes_average, Mongo::DESCENDING]], [:oldest, [:created_at, Mongo::ASCENDING]], [:newest, [:created_at, Mongo::DESCENDING]]]

  def index
    find_questions
  end

  def enable_page
    @owner = User.where(:authentication_token => params[:t]).first

    if @owner.role_on(@current_group) != "owner"
      render :text => "you dont have permissions to do this!" and return
    end

    @current_group.override(:"share.fb_page_id" => params[:fb_page_id])

    redirect_to facebook_path(:signed_request => params[:signed_request])
  end

  protected
  def find_group
    find_group_on_facebook(params[:signed_request])
  end

  def find_group_on_facebook(sr)
    if params[:group_id]
      @current_group ||= Group.find(params[:group_id])
      return
    end

    if sr.kind_of?(String)
      @signed_request = parse_signed_request(sr)
    else
      @signed_request = sr
    end

    if !@signed_request
      render :text => "sorry facebook is not working well today" and return
    end

    Rails.logger.info @signed_request.inspect

    @fb_page_id = @signed_request["page"]["id"]
    @current_group ||= Group.where(:"share.fb_page_id" => @fb_page_id, :state => "active").first

    if !@current_group && @signed_request["page"]["admin"]
      @current_user ||= User.where(:facebook_id => @signed_request["user"]["user_id"]).first

      if @current_user.authentication_token.blank?
        @current_user.reset_authentication_token
        @current_user.save(:validate => false)
      end

      render :partial => "facebook/enable_page" and return
    end

    @signed_request.delete("oauth_token")
    session[:shapado_signed_request] = @signed_request
    @current_group
  end

  def parse_signed_request(str)
    return if str.blank?

    sig, c = str.split('.')

    json = c.gsub('-','+').gsub('_','/')
    json += '=' while !(json.size % 4).zero?
    json = Base64.decode64(json)

    ActiveSupport::JSON.decode(json)
  end
end
