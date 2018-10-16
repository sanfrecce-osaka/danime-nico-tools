# frozen_string_literal: true

module EpisodesHelper
  def description_with_converted_link(episode)
    episode.description.gsub(%r((so\d+))) { link_to($1, episode_path($1)) }
  end
end
