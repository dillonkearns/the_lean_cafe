defmodule TheLeanCafe.TableController do
  use TheLeanCafe.Web, :controller

  alias TheLeanCafe.Table

  def unobfuscate(hashid) do
    id = Obfuscator.decode(hashid)
    Repo.get!(Table, id)
  end

  def index(conn, _params) do
    tables = Repo.all(Table)
    render(conn, "index.html", tables: tables)
  end

  def new(conn, _params) do
    changeset = Table.changeset(%Table{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _) do
    changeset = Table.changeset(%Table{}, %{})

    case Repo.insert(changeset) do
      {:ok, table} ->
        conn
        |> redirect(to: table_path(conn, :show, Obfuscator.encode(table.id)))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"hashid" => hashid}) do
    table = unobfuscate(hashid)
    render(conn, "show.html", table: table)
  end

end
