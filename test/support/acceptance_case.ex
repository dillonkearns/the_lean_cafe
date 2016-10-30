defmodule TheLeanCafe.AcceptanceCase do
  use ExUnit.CaseTemplate
  use Hound.Helpers

  using do
    quote do
      @moduletag :acceptance
      use Hound.Helpers

      import TheLeanCafe.Router.Helpers

      alias TheLeanCafe.Repo

      @endpoint TheLeanCafe.Endpoint
      hound_session
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TheLeanCafe.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TheLeanCafe.Repo, {:shared, self()})
    end

    :ok
  end
end
