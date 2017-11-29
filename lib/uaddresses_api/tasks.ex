defmodule :uaddresses_api_tasks do
  @moduledoc """
  Nice way to apply migrations inside a released application.

  Example:

      uaddresses_api/bin/uaddresses_api command uaddresses_api_tasks migrate!
  """
  import Mix.Ecto, warn: false

  @priv_dir "priv"
  @repo Uaddresses.Repo

  def migrate! do
    # Migrate
    migrations_dir = Application.app_dir(:uaddresses_api, "priv/repo/migrations")

    # Run migrations
    @repo
    |> start_repo()
    |> Ecto.Migrator.run(migrations_dir, :up, all: true)

    System.halt(0)
    :init.stop()
  end

  def seed! do
    seed_script = Path.join([@priv_dir, "repo", "seeds.exs"])

    # Run seed script
    start_repo(@repo)

    Code.require_file(seed_script)

    System.halt(0)
    :init.stop()
  end

  defp start_repo(repo) do
    load_app()
    {:ok, _} = repo.start_link()
    repo
  end

  defp load_app do
    start_applications([:logger, :postgrex, :ecto])
    :ok = Application.load(:uaddresses_api)
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end
end
