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

    desc 'update not watchable season yaml data'
    task not_watchable_seasons: :setup do |task|
      update_not_watchable_seasons = -> { FixtureDataTask.update_not_watchable_seasons }
      execute_task(task.name, update_not_watchable_seasons)
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

    desc 'update season yaml data to not watchable'
    task seasons_to_not_watchable: :setup do |task|
      update_to_not_watchable = -> { FixtureDataTask.update_to_not_watchable }
      execute_task(task.name, update_to_not_watchable)
    end

    desc 'update renamed season yaml data'
    task renamed_seasons: :setup do |task|
      update_renamed_seasons = -> { FixtureDataTask.update_renamed_seasons }
      execute_task(task.name, update_renamed_seasons)
    end

    desc 'update tags on season yaml data'
    task tags: :setup do |task|
      update_tags = -> { FixtureDataTask.update_tags }
      execute_task(task.name, update_tags)
    end
  end

  namespace :db do
    desc 'create uncreated season records'
    task uncreated_seasons: :setup do |task|
      create_uncreated_seasons = -> { DBDataTask.create_uncreated_seasons }
      execute_task(task.name, create_uncreated_seasons)
    end

    desc 'update on-air season records'
    task on_air_seasons: :setup do |task|
      update_on_air_seasons = -> { DBDataTask.update_on_air_seasons }
      execute_task(task.name, update_on_air_seasons)
    end

    desc 'update not watchable season records'
    task not_watchable_seasons: :setup do |task|
      update_not_watchable_seasons = -> { DBDataTask.update_not_watchable_seasons }
      execute_task(task.name, update_not_watchable_seasons)
    end

    desc 'update season records to not watchable'
    task seasons_to_not_watchable: :setup do |task|
      update_to_not_watchable = -> { DBDataTask.update_to_not_watchable }
      execute_task(task.name, update_to_not_watchable)
    end

    namespace :designated_seasons do
      desc 'update designated season records'
      task :update, ['season_title'] => :setup do |task, args|
        update_designated_seasons = -> { DBDataTask.update_designated_seasons(args.season_title) }
        execute_task(task.name, update_designated_seasons)
      end
    end
  end
end
