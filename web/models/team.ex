defmodule Pickems.Team do
  use Pickems.Web, :model

  schema "teams" do
    field :name, :string
    field :is_paid, :boolean, default: false
    belongs_to :owner, Pickems.Owner

    timestamps
  end

  @required_fields ~w(name is_paid)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end
end
