defmodule Ingest.AccessTest do
  use Ingest.DataCase

  alias Ingest.Access

  describe "policies" do
    alias Ingest.Access.Policy

    import Ingest.AccessFixtures

    @invalid_attrs %{attributes: nil, name: nil, actions: nil, resource_types: nil, matcher: nil}

    test "list_policies/2 returns policies matching resources and action" do
      valid_attrs = %{
        attributes: %{},
        name: "some name",
        actions: [:update],
        resource_types: [Ingest.Access.Policy],
        matcher: :match_all
      }

      assert {:ok, %Policy{} = policy} = Access.create_policy(valid_attrs)
      assert policies = Access.list_policies([Ingest.Access.Policy], [:update])
      assert length(policies) > 0
      assert Enum.at(policies, 0).matcher == :match_all
      assert Enum.at(policies, 0).resource_types == [Ingest.Access.Policy]

      # it's not coverage unless you test failure
      assert policies = Access.list_policies([Ingest.Access.Policy], [:create])
      assert length(policies) == 0
    end

    test "list_policies/0 returns all policies" do
      policy = policy_fixture()
      assert Access.list_policies() == [policy]
    end

    test "get_policy!/1 returns the policy with given id" do
      policy = policy_fixture()
      assert Access.get_policy!(policy.id) == policy
    end

    test "create_policy/1 with valid data creates a policy" do
      valid_attrs = %{
        attributes: %{},
        name: "some name",
        actions: [:update],
        resource_types: ["option1", "option2"],
        matcher: :match_all
      }

      assert {:ok, %Policy{} = policy} = Access.create_policy(valid_attrs)
      assert policy.attributes == %{}
      assert policy.name == "some name"
      assert policy.actions == [:update]
      assert policy.resource_types == ["option1", "option2"]
      assert policy.matcher == :match_all
    end

    test "create_policy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Access.create_policy(@invalid_attrs)
    end

    test "update_policy/2 with valid data updates the policy" do
      policy = policy_fixture()

      update_attrs = %{
        attributes: %{},
        name: "some updated name",
        actions: [:delete],
        resource_types: ["option1"],
        matcher: :match_one
      }

      assert {:ok, %Policy{} = policy} = Access.update_policy(policy, update_attrs)
      assert policy.attributes == %{}
      assert policy.name == "some updated name"
      assert policy.actions == [:delete]
      assert policy.resource_types == ["option1"]
      assert policy.matcher == :match_one
    end

    test "update_policy/2 with invalid data returns error changeset" do
      policy = policy_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.update_policy(policy, @invalid_attrs)
      assert policy == Access.get_policy!(policy.id)
    end

    test "delete_policy/1 deletes the policy" do
      policy = policy_fixture()
      assert {:ok, %Policy{}} = Access.delete_policy(policy)
      assert_raise Ecto.NoResultsError, fn -> Access.get_policy!(policy.id) end
    end

    test "change_policy/1 returns a policy changeset" do
      policy = policy_fixture()
      assert %Ecto.Changeset{} = Access.change_policy(policy)
    end
  end
end
