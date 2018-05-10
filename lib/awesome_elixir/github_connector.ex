defmodule AwesomeElixir.GithubConnector do
  @base_url "https://api.github.com/repos"
  @user_agent "awesome_elixir"
  @auth_token "208ac243733f04c042dc01a3b2ae000022ce73b4"

  def get(repo_path, options \\ []) do
    common_headers = ['User-Agent': @user_agent, 'Authorization': "token " <> @auth_token]
    headers = case options[:headers] == nil do
      false -> common_headers ++ options[:headers]
      true -> common_headers
    end

    HTTPotion.get(@base_url <> repo_path, headers: headers)
  end
end