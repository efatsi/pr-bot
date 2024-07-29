class ApplicationController < ActionController::Base

  def selected_robots
    # join available w/ cookied to ensure valid and selected robots
    available_robots & cookied_robots
  end

  helper_method :available_robots
  def available_robots
    ["gpt-4", "gpt-3", "gemini"]
  end

  helper_method :cookied_robots
  def cookied_robots
    # default this to the first robot if no cookie is set
    cookies.fetch("selectedRobots", available_robots[0]).split(",")
  end

  helper_method :file_openers
  def file_openers
    ["in_app", "vs_code"]
  end

  helper_method :cookied_file_opener
  def cookied_file_opener
    cookies.fetch("selectedFileOpener", file_openers[0])
  end
end
