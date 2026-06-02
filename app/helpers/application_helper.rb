module ApplicationHelper
  # Highlights the active navigation item in the sidebar
  def sidebar_link_class(path)
    classes = ["sidebar__link"]
    classes << "is-active" if current_page?(path)
    classes.join(" ")
  end
end
