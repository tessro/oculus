require 'oculus'

describe Oculus::User do
  it "has an ID" do
    Oculus::User.new(1).id.should == 1
  end

  it "has a name" do
    Oculus::User.new(1, "Aaron").name.should == "Aaron"
  end
end
