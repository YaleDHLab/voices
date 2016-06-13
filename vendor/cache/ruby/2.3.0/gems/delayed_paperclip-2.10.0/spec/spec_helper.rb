$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'active_record'
require 'rspec'
require 'fakeredis/rspec'
require 'mocha/api'
begin
  require 'active_job'
rescue LoadError
end

begin
  require 'pry'
rescue LoadError
  # Pry is not available, just ignore.
end

require 'paperclip/railtie'
Paperclip::Railtie.insert

require 'delayed_paperclip/railtie'
DelayedPaperclip::Railtie.insert

# silence deprecation warnings in rails 4.2
# in Rails 5 this setting is deprecated and has no effect
if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks=) && Rails::VERSION::MAJOR < 5
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

require "active_support/deprecation"
ActiveSupport::Deprecation.silenced = true

# Connect to sqlite
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => ":memory:"
)

# Path for filesystem writing
ROOT = Pathname.new(File.expand_path("../.", __FILE__))
ActiveRecord::Base.logger = Logger.new(ROOT.join("tmp/debug.log"))
Paperclip.logger = ActiveRecord::Base.logger

RSpec.configure do |config|
  config.mock_with :mocha

  config.order = :random

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    reset_global_default_options
  end
end

def reset_global_default_options
  DelayedPaperclip.options.merge!({
    :background_job_class => DelayedPaperclip::Jobs::Resque,
    :url_with_processing  => true,
    :processing_image_url => nil
  })
end

# In order to not duplicate code directly from Paperclip's spec support
# We're requiring the MockInterpolator object to be used
require Gem.find_files("../spec/support/mock_interpolator").first

Dir["./spec/integration/examples/*.rb"].sort.each { |f| require f }

# Reset table and class with image_processing column or not
def reset_dummy(options = {})
  options[:with_processed] = true unless options.key?(:with_processed)
  options[:processed_column] = options[:with_processed] unless options.has_key?(:processed_column)

  build_dummy_table(options.delete(:processed_column))
  reset_class("Dummy", options)
end

# Dummy Table for images
# with or without image_processing column
def build_dummy_table(with_column)
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.string   :name
    t.string   :image_file_name
    t.string   :image_content_type
    t.integer  :image_file_size
    t.datetime :image_updated_at
    t.boolean(:image_processing, :default => false) if with_column
  end
end

def reset_class(class_name, options)
  # setup class and include paperclip
  options[:paperclip] = {} if options[:paperclip].nil?
  ActiveRecord::Base.send(:include, Paperclip::Glue)
  Object.send(:remove_const, class_name) rescue nil

  # Set class as a constant
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

  # Setup class with paperclip and delayed paperclip
  klass.class_eval do
    include Paperclip::Glue

    has_attached_file :image, options.delete(:paperclip)

    validates_attachment :image, :content_type => { :content_type => "image/png" }

    process_in_background :image, options if options[:with_processed]

    after_update :reprocess if options[:with_after_update_callback]

    def reprocess
      image.reprocess!
    end
  end

  Rails.stubs(:root).returns(ROOT.join("tmp"))
  klass.reset_column_information
  klass
end
