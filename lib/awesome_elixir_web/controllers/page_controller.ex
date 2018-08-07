defmodule AwesomeElixirWeb.PageController do
  import Ecto.Query

  use AwesomeElixirWeb, :controller

  def index(conn, params) do
    min_stars = validate_min_stars(params["min_stars"])

    c_query = from(
                    c in AwesomeElixir.Category, 
                    join: a in AwesomeElixir.Lib, 
                    on: c.id == a.category_id, 
                    where: a.stars >= ^min_stars,
                    group_by: c.id,
                    order_by: c.name,
                  )
    a_query = from(
                    a in AwesomeElixir.Lib,
                    where: a.stars >= ^min_stars,
                    order_by: a.name
                  )

    categories = c_query |> AwesomeElixir.Repo.all
    applications = a_query |> AwesomeElixir.Repo.all
    render conn, "index.html", categories: categories, applications: applications
  end

  defp validate_min_stars(min_stars) do
    case min_stars do
      nil -> 0
      _ ->
        case Integer.parse(min_stars) do
          {int, ""} -> int
          _ -> 0
        end
    end
  end
end
