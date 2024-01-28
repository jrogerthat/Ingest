defmodule Ingest.Requests do
  @moduledoc """
  The Requests context.
  """

  import Ecto.Query, warn: false
  alias Ingest.Requests.TemplateField
  alias Ingest.Accounts.User
  alias Ingest.Projects.Project
  alias Ingest.Repo
  alias Ingest.Destinations.Destination

  alias Ingest.Requests.Template

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    Repo.all(Template)
  end

  def list_own_templates(%User{} = user) do
    Repo.all(from t in Template, where: t.inserted_by == ^user.id)
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{data: %Template{}}

  """
  def change_template(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end

  def change_template_field(%TemplateField{} = field, attrs \\ %{}) do
    TemplateField.changeset(field, attrs)
  end

  alias Ingest.Requests.Request

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Repo.all(Request)
  end

  def list_own_requests(%User{} = user) do
    Repo.all(from r in Request, where: r.inserted_by == ^user.id)
  end

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!(123)
      %Request{}

      iex> get_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request!(id),
    do:
      Repo.get!(Request, id)
      |> Repo.preload(:templates)
      |> Repo.preload(:projects)
      |> Repo.preload(:destinations)

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request(attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
    |> Repo.insert()
  end

  def create_request(
        attrs \\ %{},
        [%Template{}] = templates,
        [%Project{}] = projects,
        [%Destination{}] = destinations,
        %User{} = user
      ) do
    %Request{}
    |> Request.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:templates, templates)
    |> Ecto.Changeset.put_assoc(:projects, projects)
    |> Ecto.Changeset.put_assoc(:destinations, destinations)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a request.

  ## Examples

      iex> update_request(request, %{field: new_value})
      {:ok, %Request{}}

      iex> update_request(request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_request(%Request{} = request, attrs) do
    request
    |> Request.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking request changes.

  ## Examples

      iex> change_request(request)
      %Ecto.Changeset{data: %Request{}}

  """
  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end

  def remove_destination(%Request{} = request, %Destination{} = destination) do
    Repo.delete_all(
      from d in "request_destinations",
        where:
          d.destination_id == type(^destination.id, :binary_id) and
            d.request_id == type(^request.id, :binary_id)
    )
  end

  def remove_project(%Request{} = request, %Project{} = project) do
    Repo.delete_all(
      from d in "request_projects",
        where:
          d.project_id == type(^project.id, :binary_id) and
            d.request_id == type(^request.id, :binary_id)
    )
  end

  def remove_template(%Request{} = request, %Template{} = template) do
    Repo.delete_all(
      from d in "request_templates",
        where:
          d.template_id == type(^template.id, :binary_id) and
            d.request_id == type(^request.id, :binary_id)
    )
  end
end
