# frozen_string_literal: true

module Scraping
  class DanimeHeadStore < Base
    SEARCH_URL = 'https://anime.dmkt-sp.jp/animestore/sch_pc'
    DIFFERENT_SEASON_TITLES =
      [
        'ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei 素足のGinRei Episode.1 盗まれた戦闘チャイナを捜せ大作戦！！',
        'ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei 青い瞳の銀鈴 GinRei with blue eyes',
        '秘密結社 鷹の爪 THE MOVIE～総統は二度死ぬ～',
        '秘密結社 鷹の爪 THE MOVIE II～私を愛した黒烏龍茶～',
        '秘密結社 鷹の爪 THE MOVIE III～http://鷹の爪.jpは永遠に～'
      ].map(&:freeze).freeze

    class_attribute :season, :targets

    class << self
      def execute(season, targets = %i(tags related_seasons others))
        @season = season
        @targets = targets
        initialize_headless_driver
        set_window_size
        @driver.get("#{DanimeHeadStore::SEARCH_URL}?#{search_params(season.title)}")
        fetch_season_thumbnail_url_and_move_to_season_page
        return @season unless @season.watchable
        fetch_season_info
        fetch_related_season_titles if @targets.include?(:related_seasons)
        @season
      ensure
        @driver.quit
      end

      private

      def set_window_size
        size = @driver.manage.window.size
        @driver.manage.window.resize_to(1264, size.height)
      end

      def search_params(params)
        title = DanimeHeadStore::DIFFERENT_SEASON_TITLES.include?(params) ? modify_title(params) : params
        URI.encode_www_form(searchKey: title)
      end

      def modify_title(different_title)
        words =
          ['秘密結社 鷹の爪 ', 'ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei '].map { |word| "(#{word})" }.join('|')
        matches = different_title.match(%r((#{words})(.+)))
        "#{matches[1]} #{matches[4]}" if matches
      end

      def fetch_season_thumbnail_url_and_move_to_season_page
        logger.debug('getting thumbnail url now...')
        return @season.watchable = false if result_is_zero?
        sleep 1
        target_item =
          @driver
            .find_elements(:class, 'itemModuleIn')
            .find { |element| element.find_element(:class, 'ui-clamp').text == @season.title }
        if target_item
          @season.watchable = true
        else
          return @season.watchable = false
        end
        if @targets.include?(:others)
          @season.thumbnail_url = target_item.find_element(:tag_name, 'img').attribute('src')
        end
        target_item.click
      end

      def result_is_zero?
        @driver
          .find_element(:class, 'listHeader').find_element(:class, 'headerText').text
          .scan(%r(\d+)).first.to_i.zero?
      end

      def fetch_season_info
        logger.debug('getting season info now...')
        fetch_outline_and_genre_tags if @targets.include?(:others) || @targets.include?(:tags)
        fetch_episodes if @targets.include?(:others)
        fetch_cast_and_others if @targets.include?(:others)
        fetch_tags_other_than_genre if @targets.include?(:tags)
        fetch_related_season_links if @targets.include?(:related_seasons)
      end

      def fetch_outline_and_genre_tags
        return unless @season.watchable
        outline_container = @driver.find_element(:class, 'outlineContainer')
        @season.outline = outline_container.find_element(:tag_name, 'p').text if @targets.include?(:others)
        if @targets.include?(:tags)
          @season.tags = outline_container.find_elements(:class, 'footerLink').map do |footer_link|
            initialize_tag(footer_link.find_element(:tag_name, 'a').text, 'genre')
          end
        end
      end

      def initialize_tag(name, type)
        TagHash.new(name: name, type: type)
      end

      def fetch_episodes
        return unless @season.watchable
        begin
          episode_wrapper = @driver.find_element(:class, 'episodeWrapper')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          @season.episodes = []
          return
        end
        div, mod = episode_wrapper.find_elements(:class, 'itemModule').length.divmod(10)
        slide_count = (mod == 0) ? div : div + 1
        episodes =
          (1..slide_count).map do |loop_count|
            episode_wrapper.find_element(:class, 'btnEpisodeNext').click if loop_count != 1
            sleep 1
            fetch_episodes_from_active_slide(episode_wrapper)
          end.flatten
        episodes.reject! { |episode| episode.nonexistent_episode?(@season) } if @season.has_nonexistent_episode?
        episodes.map! { |episode| episode.update_only_different_title(@season) } if @season.has_different_title_episode?
        @season.episodes_before_updating = @season.episodes
        @season.episodes = episodes
      end

      def fetch_episodes_from_active_slide(driver_or_target)
        driver_or_target
          .find_element(:class, 'swiper-slide-active').find_elements(:class, 'itemModule')
          .map do |item_module|
            line1 = item_module.find_element(:class, 'line1')
            episode_no = line1.displayed? ? line1.text : ''
            episode_title = item_module.find_element(:class, 'line2').text
            initialize_episode(episode_no, episode_title)
          end
      end

      def initialize_episode(episode_no, episode_title)
        EpisodeHash.new(episode_no: episode_no, title: episode_title)
      end

      def fetch_cast_and_others
        cast_items = @driver.find_element(:class, 'castContainer').find_elements(:tag_name, 'p')
        cast_items.each do |p|
          text = p.text.gsub("\n", '<br>')
          case text
          when %r(キャスト)
            @season.cast = text
          when %r(スタッフ)
            @season.staff = text
          when %r(製作年)
            @season.produced_year = text
          when %r([℗©ⓒⒸ@]|([(（][cｃCＣ有][)）])|写真提供|発売元)
            @season.copyright = text
          when %r(^$)
            next
          else
            raise StandardError.new('unexpected cast is found.')
          end
        end
      end

      def fetch_tags_other_than_genre
        begin
          tag_area = @driver.find_element(:class, 'tagArea')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          return @season.tags
        end
        tag_captions = tag_area.find_elements(:class, 'tagCaption')
        tags = tag_area.find_elements(:class, 'tagWrapper')
        @season.tags.concat(
          tag_captions.map.with_index do |tag_caption, index|
            case tag_caption.text
            when 'キャスト'
              tags[index].find_elements(:tag_name, 'a').map { |tag| initialize_tag(tag.text, 'cast') }
            when 'スタッフ'
              tags[index].find_elements(:tag_name, 'a').map { |tag| initialize_tag(tag.text, 'staff') }
            when 'その他'
              tags[index].find_elements(:tag_name, 'a').map { |tag| initialize_tag(tag.text, 'other') }
            end
          end.flatten
        )
      end

      def fetch_related_season_links
        links = []
        begin
          series_related = @driver.find_element(:id, 'seriesRelated')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          return @season.related_season_links = links
        end
        related_seasons = series_related.find_elements(:class, 'itemModule')
        div, mod = related_seasons.length.divmod(4)
        total_btn_click = mod.zero? ? div - 1 : div
        (0..(total_btn_click - 1)).each do |already_btn_click_count|
          (0..3).each do |already_got_link_count|
            links.push(fetch_link_from_targets(related_seasons, already_btn_click_count * 4 + already_got_link_count))
          end
          series_related.find_element(:class, 'btnRelationNext').click unless mod.zero?
        end
        total_remaining_season = mod.zero? ? 4 : mod
        (-total_remaining_season..-1)
          .each { |position_from_last| links.push(fetch_link_from_targets(related_seasons, position_from_last)) }
        @season.related_season_links = links
      end

      def fetch_link_from_targets(targets, index)
        targets[index].find_element(:tag_name, 'a').attribute('href')
      end

      def fetch_related_season_titles
        logger.debug('getting related season titles now...')
        @season.related_seasons = @season.delete(:related_season_links).map do |link|
          @driver.get(link)
          sleep 1
          SeasonHash.new(title: @driver.find_element(:id, 'breadCrumb_d').text)
        end
      end
    end
  end
end
