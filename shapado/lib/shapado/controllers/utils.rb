module Shapado
  module Controllers
    module Utils
      def self.included(base)
        base.class_eval do
          helper_method :page_title, :feed_urls, :is_bot?, :current_tags, :bodys_class
        end
      end

      def current_tags
        @current_tags ||=  if params[:tags].kind_of?(String)
          params[:tags].split("+")
        elsif params[:tags].kind_of?(Array)
          params[:tags]
        else
          []
        end
      end

      def set_page_title(title)
        @page_title = title
      end

      def page_title
        if @page_title
          if current_group.name == AppConfig.application_name
            "#{@page_title} - #{AppConfig.application_name}: #{t("layouts.application.title")}"
          else
            if current_group.isolate
              "#{@page_title} - #{current_group.name} #{current_group.legend}"
            else
              "#{@page_title} - #{current_group.name} - #{AppConfig.application_name} -  #{current_group.legend}"
            end
          end
        else
          if current_group.name == AppConfig.application_name
            "#{AppConfig.application_name} - #{t("layouts.application.title")}"
          else
            if current_group.isolate
              "#{current_group.name} - #{current_group.legend}"
            else
              "#{current_group.name} - #{current_group.legend} - #{AppConfig.application_name}"
            end
          end
        end
      end

      def feed_urls
        @feed_urls ||= Set.new
      end

      def add_feeds_url(url, title="atom")
        feed_urls << [title, url]
      end

      def track_pageview
        if !(!request.get? || current_group.nil? || is_bot?)
          current_group.stats.viewed!
        end
      end

      def is_bot?
        request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Java|Yandex|Linguee|LWP::Simple|Exabot|ia_archiver|Purebot|Twiceler|StatusNet|Baiduspider)\b/i
      end

      def build_date(params, name)
        Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]}") rescue nil
      end

      def build_datetime(params, name)
        begin
          if params[name].is_a? Hash
            datetime = params[name]

            Time.zone.parse("#{datetime["day"]}-#{datetime["month"]}-#{datetime["year"]} #{datetime["hour"]}:#{datetime["minute"]}")
          else
            Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]} #{params["#{name}(4i)"]}:#{params["#{name}(5i)"]}")
          end
        rescue
          nil
        end
      end

      def bodys_class(params)
        controller = (params['controller'] || params[:controller]).gsub("/","-")
        out = ["#{controller}-controller", params['action']]
        if params['tab']
          out << params['tab']
        end
        if current_group && current_group.layout
          out << current_group.layout
        end
      end
    end
  end
end
