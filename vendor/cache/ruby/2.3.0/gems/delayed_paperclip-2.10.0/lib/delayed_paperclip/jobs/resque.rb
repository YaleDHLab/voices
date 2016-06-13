require 'resque'
require 'active_support/deprecation'

module DelayedPaperclip
  module Jobs
    class Resque
      def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
        @queue = instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
        ::Resque.enqueue(self, instance_klass, instance_id, attachment_name)

        ActiveSupport::Deprecation.warn(<<-MESSAGE)
Using Resque adapter for delayed_paperclip is deprecated and will be removed in version 3.0.0.
Please use ActiveJob adapter.
        MESSAGE
      end

      def self.perform(instance_klass, instance_id, attachment_name)
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
