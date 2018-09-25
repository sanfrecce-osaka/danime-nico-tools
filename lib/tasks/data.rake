# frozen_string_literal: true

namespace :data do
  task setup: :environment do
    include TaskExecutable
  end

  namespace :fixtures do
    desc 'create season list'
    task season_list: :setup do |task|
      create_season_list = -> { FixtureDataTask.create_season_list }
      execute_task(task.name, create_season_list)
    end

    desc 'show list of not watchable seasons'
    task not_watchable_season_list: :setup do |task|
      get_not_watchable_season_list = -> { FixtureDataTask.get_not_watchable_season_list }
      execute_task(task.name, get_not_watchable_season_list)
    end

    desc 'create uncreated season yaml data'
    task uncreated_seasons: :setup do |task|
      create_uncreated_seasons = -> { FixtureDataTask.create_uncreated_seasons }
      execute_task(task.name, create_uncreated_seasons)
    end

    namespace :designated_season do
      desc 'create designated season yaml data'
      task :create, ['season_title'] => :setup do |task, args|
        crate_designated_season = -> { FixtureDataTask.create_designated_season(args.season_title) }
        execute_task(task.name, crate_designated_season)
      end
    end

    namespace :designated_seasons do
      desc 'update designated season yaml data'
      task :update, ['season_title'] => :setup do |task, args|
        update_designated_seasons = -> { FixtureDataTask.update_designated_seasons(args.season_title) }
        execute_task(task.name, update_designated_seasons)
      end
    end

    desc 'update on-air season yaml data'
    task on_air_seasons: :setup do |task|
      update_on_air_seasons = -> { FixtureDataTask.update_on_air_seasons }
      execute_task(task.name, update_on_air_seasons)
    end
  end

  namespace :db do
    desc 'create uncreated season records'
    task uncreated_seasons: :setup do |task|
      create_uncreated_seasons = -> { DBDataTask.create_uncreated_seasons }
      execute_task(task.name, create_uncreated_seasons)
    end
  end
end
