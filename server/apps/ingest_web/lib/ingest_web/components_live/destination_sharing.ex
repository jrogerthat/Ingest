defmodule IngestWeb.LiveComponents.DestinationSharing do
  @moduledoc """
  This is the LiveComponent for managing the sharing of destinations with other people.
  """

  use IngestWeb, :live_component
  alias Ingest.Destinations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="sharing" rows={@members}>
        <:col :let={member} label="User">{member.user.email}</:col>
        <:col :let={member} label="Status">
          <.form
            for={}
            phx-change="update_status"
            phx-target={@myself}
            phx-value-member={member.user.id}
            phx-value-email={member.user.email}
          >
            <.input
              name="status"
              type="select"
              value={member.status}
              prompt="Select one"
              options={[Accepted: :accepted, Pending: :pending, Rejected: :rejected]}
            />
          </.form>
        </:col>
        <:col :let={member} label="Type">
          <.form
            for={}
            phx-change="update_role"
            phx-target={@myself}
            phx-value-member={member.user.id}
            phx-value-email={member.user.email}
          >
            <.input
              name="role"
              type="select"
              value={member.role}
              prompt="Select one"
              options={[Uploader: :uploader, Manager: :manager]}
            />
          </.form>
        </:col>

        <:action :let={member}>
          <.link
            :if={
              Bodyguard.permit?(
                Ingest.Destinations.Destination,
                :update_destination,
                @current_user,
                @destination
              )
            }
            phx-target={@myself}
            class="text-red-600 hover:text-red-900"
            phx-click={JS.push("revoke_access", value: %{id: member.user.id})}
            data-confirm="Are you sure?"
          >
            Revoke
          </.link>
        </:action>
      </.table>
      <.simple_form for={@invite_form} phx-submit="save" phx-target={@myself}>
        <.input
          field={@invite_form[:email]}
          type="email"
          class="shadow-sm text-black text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2.5"
          placeholder="name@deeplynx.com"
          required
          label="Invitee's Email"
        />
        <button class="flex-shrink-0 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
          Send Invite
        </button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{destination: destination} = assigns, socket) do
    {:ok,
     socket
     |> assign(:destination, destination)
     |> assign(:invite_form, to_form(%{"email" => ""}))
     |> assign(:members, Destinations.list_destination_members(destination))
     |> assign(assigns)}
  end

  @impl true
  def handle_event("save", %{"email" => email}, socket) do
    case Ingest.Destinations.add_user_to_destination_by_email(socket.assigns.destination, email) do
      {:ok, _n} ->
        {:noreply,
         socket
         |> put_flash(:info, "Succesfully Invited User!")
         |> push_patch(to: ~p"/dashboard/destinations")}

      {:error, _e} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed To Invite User!")
         |> push_patch(to: ~p"/dashboard/destinations")}
    end
  end

  @impl true
  def handle_event(
        "update_role",
        %{"role" => role, "member" => member_id} = _params,
        socket
      ) do
    case socket.assigns.destination
         |> Ingest.Destinations.update_destination_members_role(
           Enum.find(socket.assigns.destination.destination_members, fn member ->
             member.id == member_id
           end),
           String.to_existing_atom(role)
         ) do
      {1, _n} ->
        {:noreply,
         socket
         |> put_flash(:info, "Succesfully Changed Role!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}

      {:error, _e} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed To Save Role!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}
    end
  end

  @impl true
  def handle_event(
        "update_status",
        %{"status" => status, "member" => member_id} = _params,
        socket
      ) do
    case socket.assigns.destination
         |> Ingest.Destinations.update_destination_members_status(
           Enum.find(socket.assigns.destination.destination_members, fn member ->
             member.id == member_id
           end),
           String.to_existing_atom(status)
         ) do
      {1, _n} ->
        {:noreply,
         socket
         |> put_flash(:info, "Succesfully Changed Status!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}

      {:error, _e} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed To Save Status!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}
    end
  end

  @impl true
  def handle_event(
        "revoke_access",
        %{"id" => member_id} = _params,
        socket
      ) do
    case socket.assigns.destination
         |> Ingest.Destinations.remove_destination_members(member_id) do
      {1, _n} ->
        {:noreply,
         socket
         |> put_flash(:info, "Succesfully Revoked Access!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}

      {:error, _e} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to Revoke Access!")
         |> push_patch(to: ~p"/dashboard/destinations/#{socket.assigns.destination.id}/sharing")}
    end
  end
end
