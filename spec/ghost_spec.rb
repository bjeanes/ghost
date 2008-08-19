require File.dirname(__FILE__) + '/spec_helper'

describe Host, ".list" do
  it "should return an array" do
    Host.list.should be_instance_of(Array)
  end
end

describe Host, ".add" do
  it "should return true" do
    Host.add.should be_instance_of(Array)
  end
end
