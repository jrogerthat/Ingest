defmodule Ingest.Repo.Migrations.CreateDestinations do
  use Ecto.Migration

  def change do
    create table(:destinations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :s3_config, :map
      add :azure_config, :map
      add :type, :string
      add :inserted_by, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end
  end
end
