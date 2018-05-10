require Logger

defmodule AwesomeElixir.Aggregator do
  @awesome_repo "/h4cc/awesome-elixir/readme"

  def aggregate() do
    readme_raw = AwesomeElixir.GithubConnector.get(@awesome_repo, headers: ['Accept': 'application/vnd.github.v3.raw']).body
    {categories, apps} = AwesomeElixir.Parser.parse(readme_raw)

    Enum.each(categories, fn(category) -> save_category(category) end)
    Enum.map(apps, fn({category_name, items}) -> {category_name, get_repo_meta(category_name, items, [])} end)
  end

  defp get_repo_meta(_, [], result) do
    result
  end

  defp get_repo_meta(category_name, [item | tail], result) do
    result = if (URI.parse(item.url).host == nil || URI.parse(item.url).host != "github.com") do
      Logger.warn("#{item.name} has no links to github. Skip")
      result
    else
      %HTTPotion.Response{body: body, status_code: status_code} = AwesomeElixir.GithubConnector.get(URI.parse(item.url).path)

      case status_code do
        200 ->
          repo_meta = ExJSON.parse(body, :to_map)
          %{pushed_at: days_after_last_commit, stargazers_count: stars} = AwesomeElixir.Parser.parse_repo_meta(repo_meta)
          category_data = AwesomeElixir.Repo.get_by(AwesomeElixir.Category, [name: category_name])

          result ++ [save_awesome_application(%AwesomeElixir.AwesomeApplication{item | days_after_last_commit: days_after_last_commit, stars: stars, category_id: category_data.id})]
        _ ->
          Logger.warn("Failed to get metadata for #{item.url}")
          result
      end
    end

    get_repo_meta(category_name, tail, result)
  end

  defp save_category(category) do
    case AwesomeElixir.Repo.get_by(AwesomeElixir.Category, [name: category.name]) do
      nil  -> AwesomeElixir.Repo.insert(%AwesomeElixir.Category{name: category.name})
      category -> category
    end
  end

  defp save_awesome_application(application) do
    case AwesomeElixir.Repo.get_by(AwesomeElixir.AwesomeApplication, [name: application.name]) do
      nil  -> application
      saved -> saved
    end
    |> AwesomeElixir.AwesomeApplication.changeset(Map.from_struct(application))
    |> AwesomeElixir.Repo.insert_or_update
  end
end