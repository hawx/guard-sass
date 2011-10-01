module Guard
  class Sass
  
    # The formatter handles providing output to the user.
    class Formatter

      # @param opts [Hash]
      # @option opts [Boolean] :notification
      #   Whether to show notifications  
      # @option otps [Boolean] :success
      #   Whether to print success messages
      def initialize(opts={})
        @notification = opts.fetch(:notification, true)
        @success      = opts.fetch(:show_success, true)
      end
      
      # Show a success message and notification if successes are being shown.
      #
      # @param msg [String]
      # @param opts [Hash]
      def success(msg, opts={})
        if @success
          ::Guard::UI.info(msg, opts)      
          notify(opts[:notification], :image => :success)
        end
      end
      
      # Show an error message and notification.
      #
      # @param msg [String]
      # @param opts [Hash]
      def error(msg, opts={})
        ::Guard::UI.error(msg, opts)
        notify(opts[:notification], :image => :failed) 
      end
      
      # Show a system notification, if notifications are enabled.
      # 
      # @param msg [String]
      # @param opts [Hash] See http://rubydoc.info/github/guard/guard/master/Guard/Notifier.notify
      def notify(msg, opts={})
        if @notification
          ::Guard::Notifier.notify(msg, ({:title => "Guard::Sass"}).merge(opts))
        end
      end
    
    end
  end
end