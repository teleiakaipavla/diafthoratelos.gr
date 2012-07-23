module Shapado
  module Controllers
    module Locale
      def self.included(base)
        base.class_eval do
          helper_method :current_languages, :find_languages, :language_conditions, :find_valid_locale
        end
      end

      def current_languages
        @current_languages ||= find_languages.join("+")
      end

      def find_languages
        return if !current_group

        @languages ||= begin
          if AppConfig.enable_i18n
            languages = current_group.languages

            if logged_in?
              languages = current_user.languages_to_filter(current_group)
            elsif session["user.language_filter"]
              unless session["user.language_filter"] == 'any'
                languages = [session["user.language_filter"]]
              end
            elsif params[:mylangs]
              languages = params[:mylangs].split('+')
            elsif params[:feed_token] && (feed_user = User.where(:feed_token => params[:feed_token]).first)
              languages = feed_user.languages_to_filter(current_group)
            end
            languages.to_a
          else
            [(current_group.language.blank? ? "en" : current_group.language) || AppConfig.default_language]
          end
        end
      end

      def language_conditions
        conditions = {}
        find_languages
        unless @languages.blank?
          if @languages.count > 1
            conditions[:language] = { :$in => @languages}
          else
            conditions[:language] = @languages.first
          end
        end
        conditions
      end

      def available_locales; AVAILABLE_LOCALES; end

      def set_locale
        return if !current_group

        locale = AppConfig.default_language || 'en'
        if AppConfig.enable_i18n
          if logged_in?
            locale = current_user.language
            begin
              Time.zone = current_user.timezone || "UTC"
            rescue ArgumentError
              Time.zone = "UTC"
            end
          elsif params[:feed_token] && (feed_user = User.where(:feed_token => params[:feed_token]).first)
            locale = feed_user.language
          elsif params[:lang] =~ /^(\w\w)/
            locale = find_valid_locale($1)
          elsif request.env['HTTP_ACCEPT_LANGUAGE'] =~ /^(\w\w)/
            locale = find_valid_locale($1)
          end
        end
        I18n.locale = locale.to_s
      end

      def find_valid_locale(lang)
        case lang
          when /^es/
            'es-419'
          when /^pt/
            'pt-PT'
          when "fr"
            'fr'
          when "ja"
            'ja'
          when /^el/
            'el'
          else
            'en'
        end
      end
    end
  end
end
