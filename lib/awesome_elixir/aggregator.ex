require Logger

defmodule AwesomeElixir.Aggregator do
  @awesome_repo "/h4cc/awesome-elixir/readme"

  def aggregate() do
    readme_raw = AwesomeElixir.GithubConnector.get(@awesome_repo, headers: ['Accept': 'application/vnd.github.v3.raw']).body
    {categories, apps} = AwesomeElixir.Parser.parse(readme_raw)

    Enum.each(categories, fn(category) -> save_category(category) end)
    # как это можно это переписать без создания анонимной ф-ции?
    
    Enum.map(apps, fn({category_name, items}) -> {category_name, get_repo_meta(category_name, items, [])} end)
    # ф-я get_repo_meta по факту реализует свертку.
    # Улучшится ли читаемость кода если переписать это с использованием Enum.reduce
    
    #Как можно сделать удаление старых данных?
  end

  defp get_repo_meta(_, [], result) do
    result
  end

  defp get_repo_meta(category_name, [item | tail], result) do
    result = if (URI.parse(item.url).host == nil || URI.parse(item.url).host != "github.com") do
      #для чего нужна проверка на nil?
      Logger.warn("#{item.name} has no links to github. Skip")
      result
    else
      %HTTPotion.Response{body: body, status_code: status_code} = AwesomeElixir.GithubConnector.get(URI.parse(item.url).path)

      case status_code do
        200 ->
          #Как можно избавиться от вложенных условий в этой ф-ции?
          repo_meta = ExJSON.parse(body, :to_map)
          %{pushed_at: days_after_last_commit, stargazers_count: stars} = AwesomeElixir.Parser.parse_repo_meta(repo_meta)
          category_data = AwesomeElixir.Repo.get_by(AwesomeElixir.Category, [name: category_name])
          #Как можно уменьшить кол-во обращений к база для получения id категории?

          result ++ [save_awesome_application(%AwesomeElixir.Lib{item | days_after_last_commit: days_after_last_commit, stars: stars, category_id: category_data.id})]
          #почему неправильно, что метод save_smth вызывается внутри ф-ции с названием get_smth?
        _ ->
          Logger.warn("Failed to get metadata for #{item.url}")
          result
      end
      #Сколько действий/шагов/ответственностей у данной ф-ции?
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
    case AwesomeElixir.Repo.get_by(AwesomeElixir.Lib, [name: application.name]) do
      nil  -> application
      saved -> saved
    end
    #как можно переписать предыдущие 4 строки более кратко с использованием Boolean operators
    |> AwesomeElixir.Lib.changeset(Map.from_struct(application))
    |> AwesomeElixir.Repo.insert_or_update
  end
end
