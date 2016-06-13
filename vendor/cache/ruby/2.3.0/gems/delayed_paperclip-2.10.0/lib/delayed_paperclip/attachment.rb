module DelayedPaperclip
  module Attachment

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :attr_accessor, :job_is_processing

      base.send :alias_method, :post_processing_without_delay, :post_processing
      base.send :alias_method, :post_processing, :post_processing_with_delay

      base.send :alias_method, :post_processing_without_delay=, :post_processing=
      base.send :alias_method, :post_processing=, :post_processing_with_delay=

      base.send :alias_method, :save_without_prepare_enqueueing, :save
      base.send :alias_method, :save, :save_with_prepare_enqueueing
    end

    module InstanceMethods

      def delayed_options
        options[:delayed]
      end

      # Attr accessor in Paperclip
      def post_processing_with_delay
        !delay_processing? || split_processing?
      end

      def post_processing_with_delay=(value)
        @post_processing_with_delay = value
      end

      # if nil, returns whether it has delayed options
      # if set, then it returns
      def delay_processing?
        if @post_processing_with_delay.nil?
          !!delayed_options
        else
          !@post_processing_with_delay
        end
      end

      def split_processing?
        options[:only_process] && delayed_options &&
          options[:only_process] != delayed_only_process
      end

      def processing?
        column_name = :"#{@name}_processing?"
        @instance.respond_to?(column_name) && @instance.send(column_name)
      end

      def processing_style?(style)
        return false if !processing?

        !split_processing? || delayed_only_process.include?(style)
      end

      def delayed_only_process
        only_process = delayed_options.fetch(:only_process, []).dup
        only_process = only_process.call(self) if only_process.respond_to?(:call)
        only_process.map(&:to_sym)
      end

      def process_delayed!
        self.job_is_processing = true
        self.post_processing = true
        reprocess!(*delayed_only_process)
        self.job_is_processing = false
        update_processing_column
      end

      def processing_image_url
        processing_image_url = delayed_options[:processing_image_url]
        processing_image_url = processing_image_url.call(self) if processing_image_url.respond_to?(:call)
        processing_image_url
      end

      def save_with_prepare_enqueueing
        was_dirty = @dirty

        save_without_prepare_enqueueing.tap do
          if delay_processing? && was_dirty
            instance.prepare_enqueueing_for name
          end
        end
      end

      def reprocess_without_delay!(*style_args)
        @post_processing_with_delay = true
        reprocess!(*style_args)
      end

      private

      def update_processing_column
        if instance.respond_to?(:"#{name}_processing?")
          instance.send("#{name}_processing=", false)
          instance.class.where(instance.class.primary_key => instance.id).update_all({ "#{name}_processing" => false })
        end
      end

    end
  end
end
