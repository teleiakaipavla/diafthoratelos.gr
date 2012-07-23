module Questions
  class IndexView < ThemeViewBase

    # returns the HTML containing the index of questions
    def render_index
      render_buffer current_theme.questions_index_html.read
    end

    # returns the list of questions
    def foreach_question
      CollectionWrapper.new(@questions, QuestionWrapper, view_context)
    end

    # returns the questions pagination widget
    def paginate_questions
      paginate(@questions)
    end
    alias :add_paginator :paginate_questions
  end
end
