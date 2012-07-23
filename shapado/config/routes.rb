ENV["MAGENT_WEB_PATH"] = "/magent"
require 'magent_web'

ENV["BUGHUNTER_PATH"] = "/errors"
require 'bug_hunter'

Rails.application.routes.draw do
  devise_for(:users,
             :path_names => {:sign_in => 'login', :sign_out => 'logout'},
             :controllers => {:registrations => 'users', :omniauth_callbacks => "multiauth/sessions"}) do
  end
  match '/groups/:group_id/check_custom_domain' => 'groups#check_custom_domain',
  :as => 'check_custom_domain'
  match '/groups/:group_id/reset_custom_domain' => 'groups#reset_custom_domain',
   :method => :post, :as => 'reset_custom_domain'
  match '/connect' => 'users#social_connect', :method => :get, :as => :social_connect
  match '/invitations/accept' => 'invitations#accept', :method => :get, :as => :accept_invitation
  match '/disconnect_twitter_group' => 'groups#disconnect_twitter_group', :method => :get
  match '/group_twitter_request_token' => 'groups#group_twitter_request_token', :method => :get
  match 'confirm_age_welcome' => 'welcome#confirm_age', :as => :confirm_age_welcome
  match '/change_language_filter' => 'welcome#change_language_filter', :as => :change_language_filter
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/plans' => 'doc#plans', :as => :plans
  match '/chat' => 'doc#chat', :as => :chat
  match '/feedback' => 'welcome#feedback', :as => :feedback
  match '/send_feedback' => 'welcome#send_feedback', :as => :send_feedback
  match '/settings' => 'users#edit', :as => :settings
  match '/tos' => 'doc#tos', :as => :tos
  match '/privacy' => 'doc#privacy', :as => :privacy
  match '/widgets/embedded/:id' => 'widgets#embedded', :as => :embedded_widget
  match '/suggestions' => 'users#suggestions', :as => :suggestions
  match '/activities' => 'activities#index', :as => :activities
  match '/activities/:id' => 'activities#show', :as => :activity, :method => :get

  match '/update_stripe' => 'invoices#webhook', :method => :post

  get "mobile/index"

  match '/users/auth/:provider' => 'users#auth', :as => :auth_users

  match '/facebook' => "facebook#index", :as => :facebook, :method => :any
  match '/facebook/enable_page' => 'facebook#enable_page', :as => :enable_page_facebook

  mount MagentWeb.app => ENV["MAGENT_WEB_PATH"]
  mount BugHunter.app => ENV["BUGHUNTER_PATH"]

  match '/facts' => redirect("/")
  match '/users/:id/:slug' => redirect("/users/%{slug}"), :as => :user_se_url, :id => /\d+/
  resources :users do
    collection do
      get :autocomplete_for_user_login
      post :connect
      get :follow_tags
      get :unfollow_tags
      get :leave
      get :join
      post :connect
      get :new_password
    end

    member do
      post :unfollow
      post :follow
      get :answers
      get :follows
      get :activity
    end
  end

  resources :badges

  resources :searches, :path => "search", :as => "search"

  resources :pages do
    member do
      get :js
      get :css
    end
  end

  resources :announcements do
    collection do
      get :hide
    end
  end

  resources :imports do
    collection do
      post :send_confirmation
    end
  end

  get '/questions/:id/:slug' => 'questions#show', :as => :se_url, :id => /\d+/
  post '/questions/:id/start_reward' => "reward#start", :as => :start_reward
  get '/questions/:id/close_reward' => "reward#close", :as => :close_reward

  match '/answers(.format)' => 'answers#index', :as => :answers

  scope('questions') do
    resources :tags, :constraints => { :id => /\S+/ }
  end

  match 'questions/unanswered' => redirect("/questions?unanswered=1")

  resources :questions do
    resources :votes
    resources :flags
    collection do
      get :tags_for_autocomplete
      get :related_questions
      get :random

      match '/:filter' => 'questions#index', :as => :filtered, :constraints => { :filter => /all|unanswered|by_me|feed|preferred|contributed|expertise/ }
    end

    member do
      get :solve
      get :unsolve
      get :flag
      get :follow
      get :unfollow
      get :history
      get :revert
      get :diff
      get :move
      put :move_to
      get :retag
      put :retag_to
      get :remove_attachment
      get :twitter_share
    end

    resources :comments do
      resources :votes
    end

    resources :answers do
      resources :votes
      resources :flags
      member do
        get :favorite
        get :unfavorite
        get :flag
        get :history
        get :diff
        get :revert
      end

      resources :comments do
        resources :votes
      end
    end

    resources :close_requests
    resources :open_requests
  end

  match 'questions/tags/:tags' => 'tags#show', :as => :question_tag
  match 'questions/tagged/:tags' => redirect { |env, req| "/questions/tags/#{req.params[:tags].gsub(' ', '+')}" }, :tags => /.+/ #support se url

  resources :groups do
    collection do
      get :autocomplete_for_group_slug
      get :add_to_facebook
      post :join
    end

    member do
      get :allow_custom_ads
      get :disallow_custom_ads
      post :close
      post :update_card
      get :accept

      post :upgrade
      post :downgrade
      post :set_columns
    end
  end

  resources :invitations do
    member do
      post :revoke
      post :resend
    end
  end

  resources :invoices do
    member do
      get :success
    end
    collection do
      get :auto_update
      get :upcoming
    end
  end

  scope '/manage' do
    resources :widgets do
      member do
        post :move
      end
    end

    resources :themes do
      member do
        get :remove_bg_image
        put :apply
        get :ready
        get :download
      end

      collection do
        post :import
      end
    end
    resources :constrains_configs
    resources :members
  end

  scope '/manage', :as => 'manage' do
    controller 'admin/manage' do
      match 'edit_card' => :edit_card
      match 'social' => :social
      match 'properties' => :properties
      match 'theme' => :theme
      match 'actions' => :actions
      match 'stats' => :stats
      match 'reputation' => :reputation
      match 'content' => :content
      match 'invitations' => :invitations
      match 'appearance' => :appearance
      match 'access' => :access
      match 'close_group' => :close_group
    end
  end
  match '/manage/properties/:tab' => 'admin/manage#properties', :as => :manage_properties_tab

  namespace :moderate do
    resources :questions do
      collection do
        get :flagged
        get :to_close
        get :to_open
        post :manage
      end
      member do
        get :banning
        put :ban

        get :closing
        put :close
        get :opening
        put :open
      end
    end
    resources :answers do
      collection do
        post :manage
      end
      member do
        get :banning
        put :ban
      end
    end
    resources :users
  end

  match '/moderate' => 'moderate/questions#index'
#   match '/search' => 'searches#index', :as => :search
  match '/about' => 'groups#show', :as => :about
  root :to => 'questions#index'
  #match '/:controller(/:action(/:id))'
  match '*a', :to => 'public_errors#routing'
end
