require 'spec_helper'
require 'resque'

if defined? ActiveJob
  describe "Active Job with Resque backend" do
    before :each do
      DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::ActiveJob
      ActiveJob::Base.logger = nil
      ActiveJob::Base.queue_adapter = :resque
      Resque.remove_queue(:paperclip)
    end

    let(:dummy) { Dummy.new(:image => File.open("#{ROOT}/fixtures/12k.png")) }

    describe "integration tests" do
      include_examples "base usage"
    end

    def process_jobs
      worker = Resque::Worker.new(:paperclip)
      worker.process
    end

    def jobs_count(queue = :paperclip)
      Resque.size(queue)
    end
  end
end
