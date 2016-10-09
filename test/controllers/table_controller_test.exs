defmodule TheLeanCafe.TableControllerTest do
  use TheLeanCafe.ConnCase

  alias TheLeanCafe.Table
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, table_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing tables"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, table_path(conn, :new)
    assert html_response(conn, 200) =~ "New table"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, table_path(conn, :create), table: @valid_attrs
    assert table = Repo.get_by(Table, @valid_attrs)
    assert redirected_to(conn) == table_path(conn, :show, Obfuscator.encode(table.id))
  end

  test "shows chosen resource", %{conn: conn} do
    table = Repo.insert! %Table{}
    %Table{id: table_id} = table
    conn = get conn, table_path(conn, :show, Obfuscator.encode(table_id))
    assert html_response(conn, 200) =~ "Show table"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, table_path(conn, :show, -1)
    end
  end

end
