defmodule AwesomeElixir.Repo.Migrations.AddRevisionFieldToAwesomeApplications do
  use Ecto.Migration

  def change do
  	alter table("awesome_applications") do
      add :revision_at,   :utc_datetime
    end
  end
end
