require File.dirname(__FILE__) + '/spec_helper'

describe Host, ".list" do
  it "should return an array" do
    Host.list.should be_instance_of(Array)
  end
end
