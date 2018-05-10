defmodule TestPhx.Repo.Migrations.CreateAwesomeApplications do
  use Ecto.Migration

  def change do
    create table(:awesome_applications) do
      add :name, :string
      add :url, :string
      add :description, :string
      add :stars, :integer
      add :days_after_last_commit, :integer

      timestamps()
    end

  end
end
