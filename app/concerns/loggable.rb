# frozen_string_literal: true

module Loggable
  extend ActiveSupport::Concern
  included { Loggable }

  DEFAULT_DIR = './log'

  def initialize_logger(name, shift_age: 0, shift_size: 1048576)
    logger = ActiveSupport::Logger.new(output_path(name), shift_age, shift_size)
    logger.formatter = ::Logger::Formatter.new
    logger.level = Rails.logger.level
    if logger.level == 0
      console = ActiveSupport::Logger.new(STDOUT)
      logger.extend ActiveSupport::Logger.broadcast(console)
    end
    Rails.logger = logger
  end

  def logger
    Rails.logger
  end

  def start_log(name)
    logger.info("#{name} Started")
  end

  def finish_log(name)
    logger.info("#{name} Finished")
  end

  def fail_log(name)
    logger.error("#{name} Failed")
  end

  private

  def output_path(name)
    "#{Loggable::DEFAULT_DIR}/#{name}.log"
  end
end
