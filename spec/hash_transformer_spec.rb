require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HashTransformer" do
  describe "DeleteKeyTransform" do
    it "should delete keys" do
      t = HashTransformer.new{ delete_key(:foo) }
      t.transform(:foo=>1).should == {}
      t.transform(:foo=>1, :bar=>2).should == {:bar=>2}
    end
  end

  describe "MapKeyTransform" do
    it "should map keys" do
      t = HashTransformer.new{ map_key :foo, :bar }
      t.transform(:foo=>1).should == {:bar=>1}
      t.transform(:foo=>1, :baz=>2).should == {:bar=>1, :baz=>2}
    end

    it "should bork if target key exists" do
      t = HashTransformer.new{ map_key :foo, :bar }
      lambda {
        t.transform(:foo=>1, :bar=>2)
      }.should raise_error(RuntimeError)
    end
  end

  describe "HashTransformerTransform" do
    it "should transform a hash-valued key" do
      t = HashTransformer.new do
        transform_hash :foo do
          map_key :foofoo, :barbar
        end
      end
      t.transform(:foo=>{:foofoo=>1}).should == {:foo=>{:barbar=>1}}
    end
  end
end
