# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# Version 0.3.0
#
# **Gmail Reader Xenode** monitors a specific Gmail account for the first unread message from a pre-defined 
# email address set in the `sender` variable in the Configuration File. Once an email from the specific 
# sender is discovered, the Gmail Reader Xenode then sends a message to its children for each attachment 
# within the read email, where the output message data contains the content of the attachment.
#
# Configuration File Options:
#   loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
#   enabled: determines if the Xenode process is allowed to run. Expects true/false.
#   debug: enables extra debug messages in the log file. Expects true/false.
#   user_name: defines your gmail username. Expects a string.
#   passwd: defines your gmail application access token / password. Expects a string.
#   sender: defines the sender of the email to monitor. Expects a string.
#   interval: defines the number of seconds to wait before polling the Gmail account for new email. Expects a float.
#
# Example Configuration File:
#   enabled: false
#   loop_delay: 30
#   debug: false
#   user_name: "jsmith@gmaildotcom"
#   passwd: "abcdef123456"
#   sender: "jdoe@youremaildomaindotcom"
#   interval: 300
#
# Example Input: The Gmail Reader Xenode does not expect nor handle any input. 
#
# Example Output:
#   msg.data:  "This string contains the actual content of the email attachment."
#

require 'gmail'

class GmailReaderXenode
  include XenoCore::XenodeBase

  # Initialization of variables derived from @config.
  # @param [Hash] opts
  # @option opts [:log] Logger instance.
  def startup()
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    do_debug("#{mctx} - config: #{@config.inspect}")
    @last_check = Time.now.to_f
    @interval = @config.fetch(:interval, 300.0)
    @loop_delay = @config.fetch(:loop_delay, 5.0)
    @sender = @config[:sender]
  end

  # Triggers mail check for gmail account in @config on @loop_delay timer.
  # @param []
  def process
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    if @config
      @elapsed = Time.now.to_f - @last_check
      if @elapsed > @interval.to_f
        
        do_debug("#{mctx} - checking email.. elapsed = #{@elapsed}, loop_delay: #{@loop_delay}", true)

        data = get_data_from_sender()
        do_debug("#{mctx} - data from sender: #{data.inspect}")
        
        unless data.empty?
          data.each do |attachment|
            msg_out = XenoCore::Message.new()
            msg_out.data = attachment[:data]
            msg_out.context = msg_out.context || {}
            msg_out.context[:sender] = attachment[:sender]
            msg_out.context[:file_name] = attachment[:file_name]
            write_to_children(msg_out)
          end
        end
        
        @last_check = Time.now.to_f
      end
    end
  end

  # Retrieves attachments from first unread mail sent to account from target sender.
  # @return [Array] Each item is a hash that represents an attachment on the message.
  def get_data_from_sender
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    ret_val = []

    begin
      # process the first email for each sender

      Gmail.new(@config[:user_name], @config[:passwd]) do |gm|

        count = gm.inbox.count(:unread, :from => @sender)
        do_debug("#{mctx} - unread count: #{count.inspect} sender: #{@sender}", true) if @sender

        # process the first email only as this gets called every n seconds
        email = gm.inbox.emails(:unread, :from => @sender).first
        if email && !email.message.attachments.empty?
          
          email.message.attachments.each do |att|
            filename = nil
            filename = att.filename
            do_debug("#{mctx} - got filename: #{filename.inspect}", true)
            if filename
              data = ""
              data << att.decoded
              ret_val << {sender: @sender, file_name: filename, data: data}
            end
          end
          # testing only
          # email.unread!

          # mark it as read
          email.read!

        end
      end

    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end
    
    ret_val
  end

end
