module Ghost
  class << self
    attr_accessor :store

    def store
      @store ||= Ghost::Store::HostsFileStore.new(section_name: 'ghost')
    end
  end
end

require 'ghost/store/hosts_file_store'
