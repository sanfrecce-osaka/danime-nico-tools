class EpisodesController < ApplicationController
  def index
  end

  def show
    @episode = Episode.joins(:season).eager_load(:season).find_by(content_id: params[:content_id])
    unless @episode.season.watchable
      flash[:warning] = '指定された動画は現在公開されていません'
      redirect_to :episodes
    end
  end
end
