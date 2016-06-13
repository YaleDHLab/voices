shared_examples "base usage" do
  before :each do
    DelayedPaperclip.options[:url_with_processing] = true
    reset_dummy
  end

  describe "normal paperclip" do
    before :each do
      DelayedPaperclip.options[:url_with_processing] = false
      reset_dummy :with_processed => false
    end

    it "allows normal paperclip functionality" do
      Paperclip::Attachment.any_instance.expects(:post_process)
      dummy.image.delay_processing?.should be_falsey
      dummy.image.post_processing.should be_truthy
      dummy.save.should be_truthy
      File.exists?(dummy.image.path).should be_truthy
    end

    context "missing url" do
      it "does not return missing url if false globally" do
        dummy.save!
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
        process_jobs
        dummy.reload
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end

      it "does not return missing url if false on instance" do
        reset_dummy :with_processed => false, :url_with_processing => false
        dummy.save!
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
        process_jobs  # There aren't any
        dummy.reload
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end
    end

    # TODO: somewhat duplicate test of the above
    context "original url without processing column" do
      it "works normally" do
        dummy.save!
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end
    end
  end

  describe "set post processing" do
    before :each do
      reset_dummy :with_processed => true
      dummy.image.post_processing = true
    end
    it "has delay_processing is false" do
      dummy.image.delay_processing?.should be_falsey
    end

    it "post processing returns true" do
      dummy.image.post_processing.should be_truthy
    end

    it "writes the file" do
      dummy.save
      File.exists?(dummy.image.path).should be_truthy
    end
  end

  describe "without processing column" do
    before :each do
      build_dummy_table(false)
      reset_class "Dummy", :with_processed => true
      Paperclip::Attachment.any_instance.expects(:post_process).never
    end

    it "delays processing" do
      dummy.image.delay_processing?.should be_truthy
    end

    it "post_processing is false" do
      dummy.image.post_processing.should be_falsey
    end

    it "has file after save" do
      dummy.save
      File.exists?(dummy.image.path).should be_truthy
    end

  end

  describe "jobs count" do
    it "increments by 1" do
      original_job_count = jobs_count
      dummy.save
      jobs_count.should == original_job_count + 1
    end
  end

  describe "processing column not altered" do
    it "resets after job finished" do
      dummy.save!
      dummy.image_processing?.should be_truthy
      process_jobs
      dummy.reload.image_processing?.should be_falsey
    end

    context "with error" do
      before :each do
        Paperclip::Attachment.any_instance.stubs(:reprocess!).raises(StandardError.new('oops'))
      end

      it "stays true even if errored" do
        dummy.save!
        dummy.image_processing?.should be_truthy
        process_jobs
        dummy.image_processing?.should be_truthy
        dummy.reload.image_processing?.should be_truthy
      end
    end
  end

  # TODO: test appears redundant
  describe "processing is true for new record" do
    it "is true" do
      dummy.image_processing?.should be_falsey
      dummy.new_record?.should be_truthy
      dummy.save!
      dummy.reload.image_processing?.should be_truthy
    end
  end

  describe "urls" do
    it "returns missing url until job is finished" do
      dummy.save!
      dummy.image.url.should start_with("/images/original/missing.png")
      process_jobs
      dummy.reload
      dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
    end

    context "processing url" do
      before :each do
        reset_dummy :processing_image_url => "/images/original/processing.png"
      end

      it "returns processing url while processing" do
        dummy.save!
        dummy.image.url.should start_with("/images/original/processing.png")
        process_jobs
        dummy.reload
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end

      context "defaults to missing when no file" do
        it "fallsback gracefully" do
          dummy = Dummy.new()
          dummy.save!
          dummy.reload.image.url.should start_with("/images/original/missing.png")
        end
      end
    end

    context "same url if same file assigned" do
      it "falls to missing while processing" do
        dummy.save!
        dummy.image = File.open("#{ROOT}/fixtures/12k.png")
        dummy.save!
        dummy.image.url.should start_with("/images/original/missing.png")
        process_jobs
        dummy.reload.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end
    end

  end

  describe "callbacks" do
    context "paperclip callback" do
      before :each do
        Dummy.send(:define_method, :done_processing) { puts 'done' }
        Dummy.send(:after_image_post_process, :done_processing)
        Dummy.any_instance.expects(:done_processing).once
      end

      it "observes after_image_post_process" do
        dummy.save!
        process_jobs
      end
    end

    context "after_update callback" do
      before :each do
        reset_class "Dummy", :with_processed => true,
                             :with_after_update_callback => true
      end

      it "hits after_update" do
        Dummy.any_instance.expects(:reprocess).once
        dummy.save!
        process_jobs
      end
    end
  end

  describe "only_process option" do

    # TODO: This test must be faulty
    # https://github.com/jrgifford/delayed_paperclip/issues/40
    context "passed just to delayed_paperclip argument" do
      before :each do
        reset_class "Dummy", :with_processed => true, :only_process => [:thumbnail]
      end

      it "reprocesses just those" do
        Paperclip::Attachment.any_instance.expects(:reprocess!).with(:thumbnail).once
        dummy.save!
        process_jobs
      end
    end

    context "inherits from paperclip options" do
      before :each do
        reset_class "Dummy", :with_processed => true, :paperclip => { :only_process => [:thumbnail] }
      end

      it "reprocesses just those" do
        Paperclip::Attachment.any_instance.expects(:reprocess!).with(:thumbnail).once
        dummy.save!
        process_jobs
      end
    end
  end

  describe "converts image formats" do
    before :each do
      reset_class "Dummy",  :with_processed => true,
                            :paperclip => {
                              :styles => {
                                :thumbnail => ['12x12', :jpg]
                              }
                            }
    end

    it "observes the option" do
      dummy.save!
      process_jobs
      dummy.reload.image.url(:thumbnail).should start_with("/system/dummies/images/000/000/001/thumbnail/12k.jpg")
      File.exists?(dummy.image.path).should be_truthy
    end
  end

  describe "reprocess_without_delay" do
    before :each do
      DelayedPaperclip.options[:url_with_processing] = true
      reset_dummy :paperclip => {
                    :styles => {
                      :thumbnail => '12x12'
                    }
                  }
    end

    it "does not increase jobs count" do
      dummy.save!
      dummy.image_processing?.should be_truthy
      process_jobs
      dummy.reload.image_processing?.should be_falsey

      Paperclip::Attachment.any_instance.expects(:reprocess!).once

      existing_jobs = jobs_count
      dummy.image.reprocess_without_delay!(:thumbnail)
      existing_jobs.should == jobs_count

      dummy.image_processing?.should be_falsey
      File.exists?(dummy.image.path).should be_truthy
    end

  end

  describe "reprocessing_url" do

    context "interpolation of styles" do
      before :each do
        reset_dummy :processing_image_url => "/images/:style/processing.png",
                    :paperclip => {
                      :styles => {
                        :thumbnail => '12x12'
                      }
                    }
      end

      it "interpolates unporcessed image" do
        dummy.save!
        dummy.image.url.should start_with("/images/original/processing.png")
        dummy.image.url(:thumbnail).should start_with("/images/thumbnail/processing.png")
        process_jobs
        dummy.reload.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end
    end

    context "proc for reprocessing_url" do
      before :each do
        reset_dummy :processing_image_url => lambda { |attachment| attachment.instance.reprocessing_url }
        Dummy.send(:define_method, :reprocessing_url) { 'done' }
      end

      it "calls it correctly" do
        dummy.save!
        dummy.image.url.should start_with("done")
        process_jobs
        dummy.reload
        dummy.image.url.should start_with("/system/dummies/images/000/000/001/original/12k.png")
      end
    end
  end

  describe "queue option" do
    it "enqueues job with given queue name" do
      reset_dummy :queue => "custom"

      expect do
        dummy.save!
      end.to change { jobs_count("custom") }.by(1)
    end
  end
end
