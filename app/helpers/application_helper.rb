module ApplicationHelper
  # patterns to allow links in the view to quicky assess 
  # whether the current controller and view
  # are identical to the page those links represent
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def inline_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end
  
end
