defmodule AwesomeElixirWeb.PageController do
  import Ecto.Query

  use AwesomeElixirWeb, :controller

  def index(conn, params) do
    c_query = from(
                    c in AwesomeElixir.Category, 
                    join: a in AwesomeElixir.Lib, 
                    on: c.id == a.category_id, 
                    group_by: c.id,
                    order_by: c.name
                  )
    a_query = from(
                    a in AwesomeElixir.Lib,
                    order_by: a.name
                  )
    min_stars = validate_min_stars(params["min_stars"])

    if min_stars > 0 do
      c_query = c_query |> where([a], fragment("stars >= ?", ^min_stars))
      a_query = a_query |> where([a], a.stars >= ^min_stars)
    end
    #что если убрать if. Будет ли такой код легче читать, тестировать?
    #какие есть преимущества у single assignment?

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
