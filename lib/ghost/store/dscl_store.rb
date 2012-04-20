module Ghost
  module Store

    # TODO: How to write these tests without actually
    #       destroying local hosts or needing sudo?
    #
    #       How to run off OS X?
    #
    #       Setting expectations for the calling the
    #       dscl commands is basically just testing
    #       the implementation instead of the side
    #       effect. Useless tests?
    class DsclStore
      def add(host)
      end

      def all
      end

      def delete(host)
      end

      def empty
      end
    end
  end
end
