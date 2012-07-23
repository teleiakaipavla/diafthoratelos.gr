module Shapado
module Models
  module CustomHtmlMethods
    def question_prompt
      result = self.custom_html.question_prompt[I18n.locale.to_s.split("-").first]
      if result.blank?
        result = I18n.t("custom_html.question_prompt")
      end
      if result.blank?
        result = self.custom_html.question_prompt[self.language]
      end

      result
    end

    def question_help
      result = self.custom_html.question_help[I18n.locale.to_s.split("-").first]
      if result.blank?
        result = I18n.t("custom_html.question_help")
      end
      if result.blank?
        result = self.custom_html.question_help[self.language]
      end
      result
    end

    def head
      self.custom_html.head[I18n.locale.to_s.split("-").first] ||
      self.custom_html.head[self.language] || ""
    end

    def head_tag
      self.custom_html.head_tag
    end

    def footer
      return "" if !self.custom_html.footer

      self.custom_html.footer[I18n.locale.to_s.split("-").first] ||
      self.custom_html.footer[self.language] || ""
    end

    def question_prompt=(value)
      self.custom_html.question_prompt[I18n.locale.to_s.split("-").first] = value
    end

    def question_help=(value)
      self.custom_html.question_help[I18n.locale.to_s.split("-").first] = value
    end

    def head=(value)
      self.custom_html.head[I18n.locale.to_s.split("-").first] = value
    end

    def head_tag=(value)
      self.custom_html.head_tag = value
    end

    def footer=(value)
      self.custom_html.footer[I18n.locale.to_s.split("-").first] = value
    end
  end
end
end
