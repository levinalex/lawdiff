require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "apply patch" do

  before do
    @patch = Lawdiff::Document.from_file("spec/fixtures/patch_add.xml").patches.first
    @doc = Lawdiff::Document.from_file("spec/fixtures/patch_add.template.xml")
    @expected = Lawdiff::Document.from_file("spec/fixtures/patch_add.expected.xml")
  end

  it "should have patches" do
    @patch.should_not be_nil
    @doc.should_not be_nil
  end

  it "should contain document name" do
    @patch.document_name.should == "example"
  end

  it "should apply patch without errors and with expected result" do
    docs = @patch.apply(example: @doc)
    docs[:example].to_xml.to_s.should == @expected.to_xml.to_s
  end

end


