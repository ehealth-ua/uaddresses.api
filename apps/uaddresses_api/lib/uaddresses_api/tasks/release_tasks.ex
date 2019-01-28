defmodule Uaddresses.ReleaseTasks do
  @moduledoc false

  def migrate do
    migrations_dir = Application.app_dir(:uaddresses_api, "priv/repo/migrations")

    load_app()

    repo = Uaddresses.Repo
    repo.start_link()

    Ecto.Migrator.run(repo, migrations_dir, :up, all: true)

    System.halt(0)
    :init.stop()
  end

  defp load_app do
    start_applications([:logger, :postgrex, :ecto])
    Application.load(:uaddresses_api)
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end
end
