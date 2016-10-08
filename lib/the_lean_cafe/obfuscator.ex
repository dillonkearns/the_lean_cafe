defmodule Obfuscator do
  @config Hashids.new([
    salt: "123456",
    min_len: 10
  ])

  def encode(table_id) do
    Hashids.encode(@config, table_id * 98989)
  end

  def decode(table_hashid) do
    {:ok, [multiplied_table_id]} = Hashids.decode(@config, table_hashid)
    {table_id, 0} = {div(multiplied_table_id, 98989), rem(multiplied_table_id, 98989)}
    table_id
  end
end
