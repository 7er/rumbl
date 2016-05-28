ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Rumbl.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Rumbl.Repo --quiet)
Mix.Task.run "run", ~w(priv/repo/seeds.exs --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Rumbl.Repo)

