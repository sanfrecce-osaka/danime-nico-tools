#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

require "test_queue"
require "test_queue/runner/rspec"

#
# テストランナー
# Reference: https://github.com/tmm1/test-queue
#
class MyAppRSpecRunner < TestQueue::Runner::RSpec
  # def prepare(concurrency)
  # end

  def after_fork(num)
    # ワーカー別のデータベースを準備する。
    ENV.update("TEST_ENV_NUMBER" => num > 1 ? num.to_s : "")
    ActiveRecord::Base.configurations["test"]["database"] << ENV["TEST_ENV_NUMBER"]
    ActiveRecord::Tasks::DatabaseTasks.create_current
    ActiveRecord::Base.establish_connection(:test)

    Rails.application.load_tasks
    Rake::Task["db:reset"].invoke
  end

  # def around_filter(suite)
  #   $stats.timing("test.#{suite}.runtime") do
  #     yield
  #   end
  # end
end

MyAppRSpecRunner.new.execute
