module Ghost
  class << self
    attr_accessor :store

    def store
      @store ||= Ghost::Store::HostsFileStore.new
    end
  end
end

require 'ghost/store/hosts_file_store'
