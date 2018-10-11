# frozen_string_literal: true

module NavigationHelper
  def current_nav_link(regexp)
    if regexp === controller_path
      'current-nav-link'
    end
  end
end
