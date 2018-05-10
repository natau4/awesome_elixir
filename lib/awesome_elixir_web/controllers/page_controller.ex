defmodule AwesomeElixirWeb.PageController do
  use AwesomeElixirWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
