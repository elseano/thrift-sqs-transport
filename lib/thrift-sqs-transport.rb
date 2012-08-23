require 'fog'

module Thrift
  class SqsServerTransport < BaseServerTransport
    def initialize(queue_name, aws_key, aws_secret, options = {})
      @queue_name, @aws_key, @aws_secret = queue_name, aws_key, aws_secret
      @options = options
    end

    def listen
      @transport = SqsTransport.new(@queue_name, @aws_key, @aws_secret, @options)
    end

    def accept
      @transport
    end

    def close
      @transport.close if @transport
    end

    def closed?
       @transport && !@transport.open?
    end
  end

  class SqsTransport < BaseTransport

    def initialize(queue_name, aws_key, aws_secret, options = {})
      @queue_name, @aws_key, @aws_secret = queue_name, aws_key, aws_secret
      
      @delete_after_read = options[:delete]
      @max_messages = options[:messages_to_read] || 10
      @region = options[:region]
      @host = options[:host]
    end

    def open
      sqs_options = { :aws_access_key_id => @aws_key, :aws_secret_access_key => @aws_secret }
      sqs_options[:region] = @region if @region
      sqs_options[:host] = @host if @host

      @connection = Fog::AWS::SQS.new(sqs_options)
      response = @connection.create_queue(@queue_name)
      @queue_url = response.body["QueueUrl"] rescue nil
      @messages = []
    end

    def close
      @connection = nil
      @queue_url = nil
      @in_buffer = nil
      @out_buffer = nil
    end

    def open?
      !!@queue_url
    end

    def read(size)
      open unless open?
      
      if @in_buffer
        data_read = @in_buffer.read(size)

        if data_read.nil?
          @in_buffer = nil
          return read(size)
        else
          return data_read
        end
      else
        @messages += @connection.receive_message(@queue_url, 'MaxNumberOfMessages' => @max_messages).body["Message"] if @messages.length == 0
        return "" if @messages.length == 0

        message = @messages.shift

        body = message["Body"]
        receipt = message["ReceiptHandle"]
        @connection.delete_message(@queue_url, receipt) if @delete_after_read

        if message.length > size
          @in_buffer = StringIO.new(body)
          return @in_buffer.read(size)
        else
          return body
        end
      end
    end

    def write(data)
      @out_buffer ||= StringIO.new
      @out_buffer.write(data)
    end

    def flush
      data = @out_buffer.string
      @out_buffer = StringIO.new

      open unless open?
      @connection.send_message(@queue_url, data)
    end

  end
end