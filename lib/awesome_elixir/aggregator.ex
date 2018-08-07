require Logger

defmodule AwesomeElixir.Aggregator do
  import Ecto.Query

  @awesome_repo "/h4cc/awesome-elixir/readme"

  def aggregate() do
    readme_raw = AwesomeElixir.GithubConnector.get(@awesome_repo, headers: ['Accept': 'application/vnd.github.v3.raw']).body
    {categories, apps} = AwesomeElixir.Parser.parse(readme_raw)

    Enum.each(categories, fn(category) -> save_category(category) end)
    Enum.each(apps, fn({category_name, items}) -> 
        category = AwesomeElixir.Repo.get_by(AwesomeElixir.Category, [name: category_name])

        Enum.reduce(items, [], fn(app, acc) -> get_repo_meta(app, category.id, acc) end) 
          |> Enum.each(fn(app) -> save_awesome_application(app) end)

      end)

    delete_old_app
  end

  def get_repo_meta(app, category_id, result) do
    if (URI.parse(app.url).host != "github.com") do
      Logger.warn("#{app.name} has no links to github. Skip")
      result
    else
      %HTTPotion.Response{body: body, status_code: status_code} = AwesomeElixir.GithubConnector.get(URI.parse(app.url).path)

      case status_code do
        200 ->
          %{pushed_at: days_after_last_commit, stargazers_count: stars} = ExJSON.parse(body, :to_map) 
            |> AwesomeElixir.Parser.parse_repo_meta

          result ++ [%{app | days_after_last_commit: days_after_last_commit, stars: stars, category_id: category_id}]
        _ ->
          Logger.warn("Failed to get metadata for #{app.url}")
          result
      end
    end
  end

  defp save_category(category) do
    case AwesomeElixir.Repo.get_by(AwesomeElixir.Category, [name: category.name]) do
      nil  -> AwesomeElixir.Repo.insert(%AwesomeElixir.Category{name: category.name})
      category -> category
    end
  end

  defp save_awesome_application(application) do
    saved = AwesomeElixir.Repo.get_by(AwesomeElixir.Lib, [name: application.name])
    app = if saved == nil, do: application, else: saved

    app 
    |> AwesomeElixir.Lib.changeset(Map.from_struct(application))
    |> AwesomeElixir.Repo.insert_or_update
  end

  def delete_old_app(date \\ AwesomeElixir.DateTime.beginning_of_day) do
    from(a in AwesomeElixir.Lib, where: a.revision_at < ^date) |> AwesomeElixir.Repo.delete_all
  end
end