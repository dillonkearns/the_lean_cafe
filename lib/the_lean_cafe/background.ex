defmodule TheLeanCafe.Background do

  def for(TheLeanCafe.TableView, "new.html") do
    "cafebg"
  end

  def for(TheLeanCafe.TableView, "show.html") do
    "tablebg"
  end

  def for(view_module, view_template) do
    ""
  end

end
