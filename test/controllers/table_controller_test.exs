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
    assert redirected_to(conn) == table_path(conn, :index)
    assert Repo.get_by(Table, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, table_path(conn, :create), table: @invalid_attrs
    assert html_response(conn, 200) =~ "New table"
  end

  test "shows chosen resource", %{conn: conn} do
    table = Repo.insert! %Table{}
    conn = get conn, table_path(conn, :show, table)
    assert html_response(conn, 200) =~ "Show table"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, table_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    table = Repo.insert! %Table{}
    conn = get conn, table_path(conn, :edit, table)
    assert html_response(conn, 200) =~ "Edit table"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    table = Repo.insert! %Table{}
    conn = put conn, table_path(conn, :update, table), table: @valid_attrs
    assert redirected_to(conn) == table_path(conn, :show, table)
    assert Repo.get_by(Table, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    table = Repo.insert! %Table{}
    conn = put conn, table_path(conn, :update, table), table: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit table"
  end

  test "deletes chosen resource", %{conn: conn} do
    table = Repo.insert! %Table{}
    conn = delete conn, table_path(conn, :delete, table)
    assert redirected_to(conn) == table_path(conn, :index)
    refute Repo.get(Table, table.id)
  end
end
