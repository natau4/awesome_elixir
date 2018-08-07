defmodule AwesomeElixir.Lib do
  use Ecto.Schema
  import Ecto.Changeset

  schema "awesome_applications" do
    field :days_after_last_commit, :integer
    field :description, :string
    field :name, :string
    field :stars, :integer
    field :url, :string
    field :category_id, :integer
    field :revision_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(awesome_application, attrs) do
    awesome_application
    |> cast(attrs, [:name, :url, :description, :stars, :days_after_last_commit, :category_id, :revision_at])
    |> put_change(:revision_at, AwesomeElixir.DateTime.beginning_of_day)
    |> validate_required([:name, :url, :description, :stars, :days_after_last_commit, :category_id, :revision_at])
  end
end
