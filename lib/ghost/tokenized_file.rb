module Ghost
  # TODO: make it not necessarily line-based tokenization
  # TODO: make it delegate or inherit from File/IO/StringIO to allow it to be a
  #       drop-in to things expecting an IO.
  #         - Allow consumer to manipulate a real IO, and sync the contents
  #           into the real file between the tokens?
  # TODO: make this it's own gem/library. This has nothing to do (specifically)
  #       with hosts file management
  class TokenizedFile
    attr_accessor :path, :start_token, :end_token

    def initialize(path, start_token, end_token)
      self.path        = path
      self.start_token = start_token
      self.end_token   = end_token
    end

    def read
      read_capturing
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
            yield(line) if block_given?
          end
        end
      end

      lines.join
    end
  end
end
