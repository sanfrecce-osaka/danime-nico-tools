# frozen_string_literal: true

module TaskExecutable
  extend ActiveSupport::Concern
  include Loggable

  def execute_task(name, *procs)
    initialize_logger(name)
    start_log(name)

    begin
      procs.each(&:call)
      finish_log(name)
    rescue => exception
      fail_log(name)
      raise exception
    end
  end
end
