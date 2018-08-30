# frozen_string_literal: true

namespace :data do
  task setup: :environment do
    include TaskExecutable
  end

  desc 'create season list'
  task season_list: :setup do |task|
    create_season_list = -> { DataTask.create_season_list }
    execute_task(task.name, create_season_list)
  end

  directory 'db/data'

  desc 'show list of not watchable seasons'
  task not_watchable_season_list: :setup do |task|
    get_not_watchable_season_list = -> { DataTask.get_not_watchable_season_list }
    execute_task(task.name, get_not_watchable_season_list)
  end

  desc 'create uncreated season data'
  task uncreated_seasons: [:setup, 'db/data'] do |task|
    create_uncreated_seasons = -> { DataTask.create_uncreated_seasons }
    execute_task(task.name, create_uncreated_seasons)
  end

  namespace :designated_season do
    desc 'create designated season data'
    task :create, ['season_title'] => [:setup, 'db/data'] do |task, args|
      crate_designated_season = -> { DataTask.create_designated_season(args.season_title) }
      execute_task(task.name, crate_designated_season)
    end
  end

  namespace :designated_seasons do
    desc 'update designated season data'
    task :update, ['season_title'] => [:setup, 'db/data'] do |task, args|
      update_designated_seasons = -> { DataTask.update_designated_seasons(args.season_title) }
      execute_task(task.name, update_designated_seasons)
    end
  end

  desc 'update on-air season data'
  task on_air_seasons: [:setup, 'db/data'] do |task|
    update_on_air_seasons = -> { DataTask.update_on_air_seasons }
    execute_task(task.name, update_on_air_seasons)
  end
end
