defmodule AwesomeElixir.Parser do
  import AwesomeElixir.Lib

  @line_regex ~r/^\[([^]]+)\]\(([^)]+)\) - (.+)([\.\!]+)$/

  def parse(lines) do
    { blocks, _links, _options } = Earmark.Parser.parse(String.split(lines, ~r{\r\n?|\n}))

    [%Earmark.Block.Heading{} | blocks] = blocks
    [_introduction | blocks] = blocks
    [_plusone | blocks] = blocks
    [_other_curated_lists | blocks] = blocks

    [%Earmark.Block.List{blocks: tableOfContent} | blocksList ] = blocks

    [%Earmark.Block.ListItem{blocks: [%Earmark.Block.Para{} | categories]} | _tableOfContent ] = tableOfContent
    [%Earmark.Block.List{blocks: categories}] = categories
    categories = for %Earmark.Block.ListItem{blocks: [%Earmark.Block.Para{lines: [name]}]} <- categories do
      {title, _link} = parse_markdown_link(name)
      title
    end

    apps = iterate_content(blocksList, %{})
    apps = Enum.filter(apps, fn({name, _}) -> Enum.member?(categories, name) end)

    categories = for category <- categories, do: %AwesomeElixir.Category{name: category}

    {categories, apps}
  end

  def parse_repo_meta(meta) do
    stargazers_count = meta["stargazers_count"]

    {:ok, datetime, _} = DateTime.from_iso8601(meta["pushed_at"])
    pushed_at = DateTime.diff(DateTime.utc_now(), datetime) / (24 * 60 * 60) |> trunc

    %{stargazers_count: stargazers_count, pushed_at: pushed_at}
  end

  defp parse_line(line) do
    case Regex.run @line_regex, line do
      nil -> raise("Line does not match format: '#{line}' Is there a dot at the end?")
      [^line, name, link, description, _dot] -> [name, link, description]
    end
  end

  defp parse_markdown_link(string) do
    [^string, title, link] = Regex.run ~r/\[(.+)\]\((.+)\)/, string
    {title, link}
  end

  defp iterate_content([], result) do
    result
  end

  defp iterate_content(
            [
              %Earmark.Block.Heading{content: heading, level: 2}, 
              %Earmark.Block.Para{lines: _lines}, 
              %Earmark.Block.List{blocks: blocks, type: :ul} | tail
            ], 
            result
            ) do
    result = Map.put_new(result, heading, check_list(blocks))
    iterate_content(tail, result)
  end

  defp iterate_content([_head | tail], result) do
    iterate_content(tail, result)
  end

  defp check_list(list) do
    for listItem <- list, do: validate_list_item(listItem)
  end

  defp validate_list_item(%Earmark.Block.ListItem{blocks: [%Earmark.Block.Para{lines: [line]}], type: :ul}) do
    line = case String.starts_with?(line, "~~") and String.ends_with?(line, "~~") do
      true ->
        line |> String.rstrip() |> String.strip(?~)
      false ->
        String.rstrip(line)
    end
    [name, link, description] = parse_line(line)
    %AwesomeElixir.Lib{name: name, url: link, description: description}
  end
end