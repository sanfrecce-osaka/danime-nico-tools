# frozen_string_literal: true

class BaseHash < Hashie::Mash
  def update_by(hash)
    hash.each { |key, value| eval "self.#{key.to_s} = '#{value}'" }
  end
end
