# frozen_string_literal: true

module HashieCreatable
  extend ActiveSupport::Concern
  included { extend HashieCreatable }

  def hashie(hash = {})
    Hashie::Mash.new(hash)
  end
end
