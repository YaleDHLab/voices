require 'spec_helper'

describe "Base Delayed Paperclip Integration" do
  before :each do
    DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::Resque
    Resque.remove_queue(:paperclip)
  end

  let(:dummy) { Dummy.create }

  before :each do
    reset_dummy(paperclip: { default_url: "/../../fixtures/missing.png" })
  end

  describe "double save" do
    before :each do
      dummy.image_processing.should be_falsey
      dummy.image = File.open("#{ROOT}/fixtures/12k.png")
      dummy.save!
    end

    it "processing column remains true" do
      dummy.image_processing.should be_truthy
      dummy.save!
      dummy.image_processing.should be_truthy
    end
  end
end
