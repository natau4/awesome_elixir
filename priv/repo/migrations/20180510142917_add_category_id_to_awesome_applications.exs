defmodule TestPhx.Repo.Migrations.AddCategoryIdToAwesomeApplications do
  use Ecto.Migration

  def change do
    alter table("awesome_applications") do
      add :category_id,   :integer
    end
  end
end
