defmodule Uaddresses.ReleaseTasks do
  @moduledoc false

  require Logger

  def migrate do
    if System.get_env("DB_MIGRATE") == "true" do
      Logger.info("[WARNING] Migrating database!")
      migrations_dir = Application.app_dir(:uaddresses_api, "priv/repo/migrations")

      load_app()

      repo = Uaddresses.Repo
      repo.start_link()

      Ecto.Migrator.run(repo, migrations_dir, :up, all: true)
    end

    System.halt(0)
    :init.stop()
  end

  defp load_app do
    start_applications([:logger, :postgrex, :ecto, :ecto_sql])
    Application.load(:uaddresses_api)
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end
end
