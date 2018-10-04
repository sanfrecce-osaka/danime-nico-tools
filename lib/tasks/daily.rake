namespace :daily do
  task setup: :environment do
    include TaskExecutable
  end

  namespace :update do
    task fixtures: :setup do |task|
      update_fixtures = -> { DailyTask.update_fixtures }
      execute_task(task.name, update_fixtures)
    end

    task db: :setup do |task|
      update_db = -> { DailyTask.update_db }
      execute_task(task.name, update_db)
    end
  end
end
