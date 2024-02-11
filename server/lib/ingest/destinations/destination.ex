defmodule Ingest.Destinations.Destination do
  @moduledoc """
  Destination represents the destination for data that's been uploaded to the system.
  Typically this reflects the HTTP uploads, but can hopefully be configured in the future
  to work with the high-speed UDP file transers as well.
  """
  alias Ingest.Destinations.TemporaryConfig
  alias Ingest.Destinations.AzureConfig
  alias Ingest.Destinations.S3Config
  alias Ingest.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "destinations" do
    field :name, :string
    # internal storage are those methods provided by the Ingest application administrators
    field :type, Ecto.Enum, values: [:s3, :internal, :azure, :temporary], default: :temporary

    belongs_to :user, User, type: :binary_id, foreign_key: :inserted_by
    embeds_one :s3_config, S3Config
    embeds_one :azure_config, AzureConfig
    embeds_one :temporary_config, TemporaryConfig

    timestamps()
  end

  @doc false
  def changeset(destination, attrs) do
    destination
    |> cast(attrs, [:name, :type, :inserted_by])
    |> cast_embed(:s3_config, require: false)
    |> cast_embed(:azure_config, require: false)
    |> cast_embed(:temporary_config, required: false)
    |> validate_required([:name, :type])
  end
end

defmodule Ingest.Destinations.S3Config do
  @moduledoc """
  S3 bucket configuration storage
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :api_key, Ingest.Encrypted.Binary
    field :api_secret, Ingest.Encrypted.Binary
    field :bucket, Ingest.Encrypted.Binary
    field :path, Ingest.Encrypted.Binary
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:api_key, :api_secret, :bucket, :path])
    |> validate_required([:api_key, :api_secret, :bucket, :path])
  end
end

defmodule Ingest.Destinations.AzureConfig do
  @moduledoc """
  Azure blob/datalake configuration storage
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :connection_string, Ingest.Encrypted.Binary
    field :path, Ingest.Encrypted.Binary
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:connection_string, :path])
    |> validate_required([:connection_string, :path])
  end
end

defmodule Ingest.Destinations.TemporaryConfig do
  @moduledoc """
  Temporary storage configuration
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :limit, :integer
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:limit])
    |> validate_required([:limit])
    |> validate_number(:limit, less_than_or_equal_to: 30)
  end
end
