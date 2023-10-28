defmodule Ingest.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ingest.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        status: "some status"
      })
      |> Ingest.Projects.create_project()

    project
    |> Ingest.Repo.preload(:project_members)
    |> Ingest.Repo.preload(:requests)
  end
end
