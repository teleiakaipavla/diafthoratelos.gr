class Mongoid::Logger
  def debug(message)
    op =
      case message
      when /insert/       then "\e[0;32m(C)\e[0m"
      when /find|cursor/  then "\e[0;34m(F)\e[0m"
      when /update/       then "\e[0;33m(U)\e[0m"
      when /remove/       then "\e[0;31m(D)\e[0m"
      end
    logger.debug("#{op} #{message}") if logger && logger.respond_to?(:debug)
  end
end
