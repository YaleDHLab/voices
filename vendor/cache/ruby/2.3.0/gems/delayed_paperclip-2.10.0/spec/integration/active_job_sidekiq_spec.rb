require 'spec_helper'
require 'sidekiq/testing'

describe "ActiveJob with Sidekiq backend" do
  if defined? ActiveJob
    before :each do
      DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::ActiveJob
      ActiveJob::Base.logger = nil
      ActiveJob::Base.queue_adapter = :sidekiq
      Sidekiq::Queues["paperclip"].clear
    end

    let(:dummy) { Dummy.new(:image => File.open("#{ROOT}/fixtures/12k.png")) }

    describe "integration tests" do
      include_examples "base usage"
    end
  end

  def process_jobs
    Sidekiq::Queues["paperclip"].each do |job|
      worker = job["class"].constantize.new
      args   = job["args"]
      begin
        worker.perform(*args)
      rescue # Assume sidekiq handle exception properly
      end
    end
  end

  def jobs_count(queue = "paperclip")
    Sidekiq::Queues[queue].size
  end
end
