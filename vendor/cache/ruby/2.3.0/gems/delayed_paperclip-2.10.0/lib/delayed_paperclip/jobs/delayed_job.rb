require 'delayed_job'
require 'active_support/deprecation'

module DelayedPaperclip
  module Jobs
    class DelayedJob < Struct.new(:instance_klass, :instance_id, :attachment_name)

      # This is available in newer versions of DelayedJob. Using the newee Job api thus.
      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0")

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ActiveSupport::Deprecation.warn(<<-MESSAGE)
Using DelayedJob adapter for delayed_paperclip is deprecated and will be removed in version 3.0.0.
Please use ActiveJob adapter.
          MESSAGE

          ::Delayed::Job.enqueue(
            :payload_object => new(instance_klass, instance_id, attachment_name),
            :priority => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            :queue => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      else

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ActiveSupport::Deprecation.warn(<<-MESSAGE)
Using DelayedJob adapter for delayed_paperclip is deprecated and will be removed in version 3.0.0.
Please use ActiveJob adapter.
          MESSAGE

          ::Delayed::Job.enqueue(
            new(instance_klass, instance_id, attachment_name),
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      end

      def perform
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
