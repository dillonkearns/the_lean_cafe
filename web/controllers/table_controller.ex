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
      {:ok, _table} ->
        conn
        |> put_flash(:info, "Table created successfully.")
        |> redirect(to: table_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"hashid" => hashid}) do
    table = unobfuscate(hashid)
    render(conn, "show.html", table: table)
  end

  def edit(conn, %{"id" => id}) do
    table = Repo.get!(Table, id)
    changeset = Table.changeset(table)
    render(conn, "edit.html", table: table, changeset: changeset)
  end

  def update(conn, %{"id" => id, "table" => table_params}) do
    table = Repo.get!(Table, id)
    changeset = Table.changeset(table, table_params)

    case Repo.update(changeset) do
      {:ok, table} ->
        conn
        |> put_flash(:info, "Table updated successfully.")
        |> redirect(to: table_path(conn, :show, table))
      {:error, changeset} ->
        render(conn, "edit.html", table: table, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    table = Repo.get!(Table, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(table)

    conn
    |> put_flash(:info, "Table deleted successfully.")
    |> redirect(to: table_path(conn, :index))
  end
end
