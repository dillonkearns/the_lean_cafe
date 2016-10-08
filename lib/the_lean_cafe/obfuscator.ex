defmodule Obfuscator do
  @config Hashids.new([
    salt: "123456",
    min_len: 10
  ])

  @salt_array Enum.to_list(1..10)

  def encode(table_id) do
    Hashids.encode(@config, [table_id] ++ @salt_array)
  end

  def decode(table_hashid) do
    {:ok, array} = Hashids.decode(@config, table_hashid)

    case array do
      [table_id | @salt_array] -> table_id
      _ -> -1
    end
  end
end
