defmodule GuildaWeb.RequestContext do
  @moduledoc false
  alias Guilda.AuditLog
  alias Guilda.Extensions.Ecto.IPAddress

  def put_audit_context(conn_or_socket, opts \\ [])

  def put_audit_context(%Plug.Conn{} = conn, _) do
    user_agent =
      case List.keyfind(conn.req_headers, "user-agent", 0) do
        {_, value} -> value
        _ -> nil
      end

    Plug.Conn.assign(conn, :audit_context, %AuditLog{
      user_agent: user_agent,
      ip_address: get_ip(conn.req_headers),
      user: conn.assigns[:current_user]
    })
  end

  def put_audit_context(%Phoenix.LiveView.Socket{} = socket, _) do
    audit_context = %AuditLog{
      user: socket.assigns[:current_user]
    }

    Phoenix.Component.assign_new(socket, :audit_context, fn -> audit_context end)
  end

  defp get_ip(headers) do
    with {_, ip} <- List.keyfind(headers, "x-forwarded-for", 0),
         [ip | _] = String.split(ip, ","),
         {:ok, address} <- IPAddress.cast(ip) do
      address
    else
      _ ->
        nil
    end
  end
end
