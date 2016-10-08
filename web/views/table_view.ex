defmodule TheLeanCafe.TableView do
  use TheLeanCafe.Web, :view

  def obfuscate(%TheLeanCafe.Table{id: id}) do
    Obfuscator.encode(id)
  end

  def unobfuscate(hashid) do
    id = Obfuscator.decode(hashid)
    Repo.get!(Table, id)
  end

end
