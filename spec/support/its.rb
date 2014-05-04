module MiniTest
  class Spec
    def self.its(attr, &block)
      it attr.to_s do
        subject.send(:attr).instance_eval(&block)
      end
    end
  end
end
