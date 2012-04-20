module Ghost
  # TODO: make it not necessarily line-based tokenization
  # TODO: make it delegate or inherit from File to allow it to be a drop-in
  #       to things expecting a File
  class TokenizedFile
    attr_accessor :path, :start_token, :end_token

    def initialize(path, start_token, end_token)
      self.path        = path
      self.start_token = start_token
      self.end_token   = end_token
    end

    def read
      read_capturing { }
    end

    def write(content)
      existing_lines = []

      # TODO: how to do this without closing the file so
      #       we can reopen with write mode and maintain a
      #       lock
      read_capturing { |line| existing_lines << line}

      # TODO: lock file
      File.open(path, 'w') do |file|
        file.puts(existing_lines)

        unless content.nil? || content.empty?
          file.puts(start_token)
          file.puts(content)
          file.puts(end_token)
        end
      end
    end

    private

    def read_capturing
      between_tokens = false
      lines = []

      File.open(path, 'r') do |file|
        file.each_line do |line|
          if line =~ /^#{start_token}\s*$/
            between_tokens = true
          elsif line =~ /^#{end_token}\s*$/
            between_tokens = false
          elsif between_tokens
            lines << line
          else
            yield(line)
          end
        end
      end

      lines.join
    end
  end
end
