module Ghost
  class << self
    attr_accessor :store
  end
end


require 'ghost/store/hosts_file_store'
Ghost.store = Ghost::Store::HostsFileStore.new
