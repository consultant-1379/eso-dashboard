require 'dotenv'
Dotenv.load
require 'logger'
class Log
  attr_accessor :logger

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.datetime_format = "%Y/%m/%d @ %H:%M:%S "
  end

  def method_missing(method_name, *args, &block)
    logger.send(method_name, *args, &block)
  end

  @@instance = Log.new

  def self.instance
    return @@instance
  end

  private_class_method :new
end
