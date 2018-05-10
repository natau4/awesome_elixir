defmodule TestPhx.AwesomeApplication do
  use Ecto.Schema
  import Ecto.Changeset


  schema "awesome_applications" do
    field :days_after_last_commit, :integer
    field :description, :string
    field :name, :string
    field :stars, :integer
    field :url, :string
    field :category_id, :integer

    timestamps()
  end

  @doc false
  def changeset(awesome_application, attrs) do
    awesome_application
    |> cast(attrs, [:name, :url, :description, :stars, :days_after_last_commit, :category_id])
    |> validate_required([:name, :url, :description, :stars, :days_after_last_commit, :category_id])
  end
end
