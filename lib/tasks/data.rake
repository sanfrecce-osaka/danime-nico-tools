# frozen_string_literal: true

include TaskExecutable

namespace :data do
  desc 'create season list'
  task season_list: DataTask::SEASON_LIST_PATH do |task|
    create_season_list = -> { DataTask.create_season_list }
    execute_task(task.name, create_season_list)
  end

  file DataTask::SEASON_LIST_PATH do
    YAMLFile.write(DataTask::SEASON_LIST_PATH, [])
  end

  directory 'db/data'

  desc 'show list of not watchable seasons'
  task :not_watchable_season_list do |task|
    get_not_watchable_season_list = -> { DataTask.get_not_watchable_season_list }
    execute_task(task.name, get_not_watchable_season_list)
  end

  desc 'create uncreated season data'
  task uncreated_seasons: 'db/data' do |task|
    create_uncreated_seasons = -> { DataTask.create_uncreated_seasons }
    execute_task(task.name, create_uncreated_seasons)
  end

  namespace :designated_season do
    desc 'create designated season data'
    task create: 'db/data' do |task|
      crate_designated_season = -> { DataTask.create_designated_season(ENV['season_title']) }
      execute_task(task.name, crate_designated_season)
    end
  end

  namespace :designated_seasons do
    desc 'update designated season data'
    task update: 'db/data' do |task|
      update_designated_seasons = -> { DataTask.update_designated_seasons(ENV['season_title']) }
      execute_task(task.name, update_designated_seasons)
    end
  end

  desc 'update on-air season data'
  task on_air_seasons: 'db/data' do |task|
    update_on_air_seasons = -> { DataTask.update_on_air_seasons }
    execute_task(task.name, update_on_air_seasons)
  end
end
