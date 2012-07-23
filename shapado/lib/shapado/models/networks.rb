module Shapado
module Models
  module Networks
    extend ActiveSupport::Concern

    SHARE = [["twitter", "username"],["facebook", "url"],["google", "url"]]
    PROFILE =  [["twitter", "username"],["facebook", "url"],["digg", "username"], ["youtube", "channel"],
    ["flickr", "url"], ["linkedin", "username"], ["blog", "url"], ["github", "username"],
    ['lastfm', "username"], ['reddit', "username"], ['ohloh', "username"]]

    #InstanceMethods
    def find_networks(params)
      r = {}
      (params||[]).each do |network|
        next if network["name"].blank?
        r[network["name"]] = case network["name"]
        when "facebook"
          if network["param"] =~ /facebook\.com\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "facebook.com/#{network["param"]}"}
          end
        when "twitter"
          if network["param"] =~ /twitter\.com\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "twitter.com/#{network["param"]}"}
          end
        when "flickr"
          if network["param"] =~ /flickr\.com\/photos\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "flickr.com/photos/#{network["param"]}"}
          end
        when "github"
          if network["param"] =~ /github\.com\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "github.com/#{network["param"]}"}
          end
        when "digg"
          if network["param"] =~ /digg\.com\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "digg.com/#{network["param"]}"}
          end
        when "youtube"
          if network["param"] =~ /youtube\.com\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "youtube.com/#{network["param"]}"}
          end
        when "linkedin"
          if network["param"] =~ /linkedin\.com\/(in|pub)\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "linkedin.com/pub/#{network["param"]}"}
          end
        when "blog"
          {:nickname => network["param"], :url => network["param"]}
        when "lastfm"
          if network["param"] =~ /last\.fm\/user\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "last.fm/user/#{network["param"]}"}
          end
        when "ohloh"
          if network["param"] =~ /ohloh\.net\/accounts\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "ohloh.net/accounts/#{network["param"]}"}
          end
        when "reddit"
          if network["param"] =~ /reddit\.com\/user\/([^\/\?]+)/
            {:nickname => $1, :url => network["param"]}
          else
            {:nickname => network["param"], :url => "reddit.com/user/#{network["param"]}"}
          end
        when "google"
          {}
        end
      end
      r
    end
  end
end
end
