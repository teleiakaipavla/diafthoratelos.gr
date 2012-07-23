module Shapado
  class FileWrapper
    attr_reader :path, :content_type
    def initialize(path, content_type)
      @path = path
      @content_type = content_type
    end

    def get
      self
    end

    def get_file
      @file ||= File.open(path, "r")
    end

    def size
      get_file.lstat.size
    end

    def content_type
      @content_type
    end

    def read(size)
      part = get_file.read(size)
      self.close if part.blank?
      part
    end

    def close(*args)
      get_file.close
    end
  end
end