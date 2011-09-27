module Guard
  class Sass
  
    class Formatter

      # @param opts [Hash]
      # @option opts [Boolean] :notification
      #   Whether to show notifications  
      # @option otps [Boolean] :success
      #   Whether to print success messages
      #
      def initialize(opts={})
        @notification = opts.fetch(:notification, true)
        @success      = opts.fetch(:show_success, true)
      end
      
      def success(msg, opts={})
        if @success
          ::Guard::UI.info(msg, opts.merge({:reset => true}))      
          notify(opts[:notification], :image => :success)
        end
      end
      
      def error(msg, opts={})
        ::Guard::UI.error(msg, opts.merge({:reset => true}))
        notify(opts[:notification], :image => :failed) 
      end
      
      def notify(msg, opts={})
        if @notification
          ::Guard::Notifier.notify(msg, opts.merge({:title => "Guard::Sass"}))
        end
      end
    
    end
  end
end