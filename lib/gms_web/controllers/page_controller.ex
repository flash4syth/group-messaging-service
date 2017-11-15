defmodule GMSWeb.PageController do
  use GMSWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
