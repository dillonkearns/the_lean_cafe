defmodule TheLeanCafe.TableView do
  use TheLeanCafe.Web, :view

  @salt Hashids.new([
    salt: "123456",
    min_len: 16,
  ])

  def obfuscate(%TheLeanCafe.Table{id: id}) do
    Hashids.encode(@salt, id)
  end
end
