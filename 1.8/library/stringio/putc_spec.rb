require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "StringIO#printf when in read-only mode" do
  it "raises an IOError" do
    io = StringIO.new("test", "r")
    lambda { io.putc(?a) }.should raise_error(IOError)

    io = StringIO.new("test")
    io.close_write
    lambda { io.putc("t") }.should raise_error(IOError)
  end
end

describe "StringIO#printf when in append mode" do
  it "appends to the end of self" do
    io = StringIO.new("test", "a")
    io.putc(?t)
    io.string.should == "testt"
  end
end

describe "StringIO#putc when passed [String]" do
  before(:each) do
    @io = StringIO.new('example')
  end
  
  it "overwrites the character at the current position" do
    @io.putc("t")
    @io.string.should == "txample"
    
    @io.pos = 3
    @io.putc("t")
    @io.string.should == "txatple"
  end
  
  it "only writes the first character from the passed String" do
    @io.putc("test")
    @io.string.should == "txample"
  end

  it "correctly updates the current position" do
    @io.putc("t")
    @io.pos.should == 1
    
    @io.putc("t")
    @io.pos.should == 2
    
    @io.putc("t")
    @io.pos.should == 3
  end
end

describe "StringIO#putc when passed [Object]" do
  before(:each) do
    @io = StringIO.new('example')
  end

  it "it writes the passed Integer % 256 to self" do
    @io.putc(333) # 333 % 256 == ?M
    @io.string.should == "Mxample"
    
    @io.putc(-450) # -450 % 256 == ?>
    @io.string.should == "M>ample"
  end

  it "tries to convert the passed argument to an Integer using #to_int" do
    obj = mock('to_int')
    obj.should_receive(:to_int).and_return(?t)
    @io.putc(obj)
    @io.string.should == "txample"
  end
  
  ruby_version_is "" ... "1.8.7" do
    it "checks whether the passed argument responds to #to_int" do
      obj = mock('method_missing to_int')
      obj.should_receive(:respond_to?).with(:to_int).and_return(true)
      obj.should_receive(:method_missing).with(:to_int).and_return(?t)
      @io.putc(obj)
      @io.string.should == "txample"
    end
  end

  ruby_version_is "1.8.7" do
    it "checks whether the passed argument responds to #to_int (including private methods)" do
      obj = mock('method_missing to_int')
      obj.should_receive(:respond_to?).with(:to_int, true).and_return(true)
      obj.should_receive(:method_missing).with(:to_int).and_return(?t)
      @io.putc(obj)
      @io.string.should == "txample"
    end
  end
  
  it "raises a TypeError when the passed argument can't be coerced to Integer" do
    lambda { @io.putc(Object.new) }.should raise_error(TypeError)
  end
end