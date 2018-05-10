defmodule TestPhx.Repo.Migrations.AddContactsTable do
  use Ecto.Migration

  def change do

    create table("contacts") do
      add :first,       :string
      add :second,      :string
      add :birth_day,   :utc_datetime

      timestamps()
    end

  end
end
