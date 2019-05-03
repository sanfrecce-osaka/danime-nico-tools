# frozen_string_literal: true

module Api
  class NicoContentsSearch
    include HashieCreatable
    include Loggable
    include CharWidthConvertable

    URL = 'http://api.search.nicovideo.jp/api/v2/video/contents/search'
    SPECIAL_CHAR = %w(' " - ´ ` Д 口 ￣ ∀ # [[:space:]]).map(&:freeze).freeze

    class << self
      def add_episode_info(season)
        logger.debug('accessing nico contents search now...')
        return season unless season.watchable
        return season if season.not_begin_yet?
        episodes = season.episodes.map.with_index(1) do |episode, overall_number|
          season.add_current_content_id(episode, overall_number)
          params =
            create_params(
              q: [season.title, episode.episode_no, episode.title, 'dアニメ'].select(&:present?).join('　'),
              targets: %w(title tags).join(',')
            )
          results = search(params)
          episode = results.length.zero? ? nil : merge_episode(episode, find_episode(results, season, episode))
          break if episode.nil?
          season.add_before_episode(episode, overall_number)
          episode
        end
        episodes_before_updating = season.delete(:episodes_before_updating)
        season.episodes = episodes.nil? ? episodes_before_updating : episodes
        season.watchable = false if episodes.nil?
        season
      end

      private

      def create_params(params)
        {
          q: CGI.escape(special_char_to_space(params[:q])),
          targets: CGI.escape(params[:targets]),
          fields: %w(
            title
            contentId
            description
            threadId
            channelId
            lengthSeconds
            thumbnailUrl
          ).join('%2C'),
          _sort: 'startTime',
          _limit: 100,
          _context: 'd-nico-tools'
        }.map { |key, value| "#{key}=#{value}" }.join('&')
      end

      def special_char_to_space(q)
        NicoContentsSearch::SPECIAL_CHAR.inject(q) { |b, c| b.gsub(%r(#{c}), ' ') }
      end

      def search(params)
        uri = URI.parse("#{Api::NicoContentsSearch::URL}?#{params}")
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          http.get(uri.request_uri)
        end

        case response
        when Net::HTTPSuccess
          hashie(JSON.parse(response.body)).data
        else
          logger.error "HTTP ERROR: code=#{response.code} message=#{response.message}"
          nil
        end
      end

      def find_episode(results, season, episode)
        found_result =
          if season.key?(:current_content_id)
            target_content_id = season.delete(:current_content_id)
            results.find { |result| result.contentId == target_content_id }
          else
            results.find { |result| full_to_half(result.title) =~ %r(#{target_title_for_regexp(season, episode)}$) }
          end
        if found_result
          found_result
        else
          error_message =
            <<~ERROR
              result not found
              params: #{[season.title, episode.episode_no, episode.title, 'dアニメ'].select(&:present?).join('　')}"
              target_title: #{results.present? ? full_to_half(results.first.title) : ''}
              regexp: #{%r(#{target_title_for_regexp(season, episode)}$)}
            ERROR
          logger.error(error_message)
          raise StandardError
        end
      end

      def target_title_for_regexp(season, episode)
        [season.original_or_different_title, episode.episode_no, episode.title]
          .reject(&:nil?)
          .map { |el| full_to_half(Regexp.escape(el).gsub("'", '.')) }
          .join('[[:blank:]]*')
      end

      def merge_episode(episode, result)
        result.map { |key, _| key }.each do |key|
          if key == 'threadId'
            episode.default_thread_id = result.threadId
          elsif key == 'title'
            result.delete('title')
          else
            eval "episode.#{key.underscore} = result.#{key}"
          end
        end
        episode
      end
    end
  end
end
