defmodule IngestWeb.DashboardLive do
  use IngestWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket, layout: {IngestWeb.Layouts, :dashboard}}
  end
end
