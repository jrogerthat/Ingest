defmodule Ingest.Access.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "policies" do
    field :attributes, :map
    field :name, :string
    field :actions, {:array, Ecto.Enum}, values: [:create, :read, :update, :delete]
    field :scope, Ecto.Enum, values: [:global, :user, :group]
    field :scope_id, :binary_id
    field :resource_types, {:array, EctoResourceType}
    field :matcher, Ecto.Enum, values: [:match_one, :match_none, :match_all]

    timestamps()
  end

  @doc false
  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [:name, :actions, :resource_types, :attributes, :matcher, :scope])
    |> validate_required([:name, :actions, :resource_types, :matcher, :scope])
  end
end
