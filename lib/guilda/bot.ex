defmodule Guilda.Bot do
  @bot :guilda

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  import GuildaWeb.Gettext

  alias Guilda.Accounts

  command("start")
  command("help", description: "Print the bot's help")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end

  def handle({:location, %{latitude: lat, longitude: lng}}, context) do
    from = context.update.message.from

    with {:user, {:ok, user}} <- {:user, Accounts.upsert_user(Map.put(from, :telegram_id, Kernel.to_string(from.id)))},
         {:location, {:ok, user}} <- {:location, Accounts.set_lng_lat(user, lng, lat)} do
      answer(context, gettext("Sua localização foi salva com sucesso!"))
    else
      {:user, {:error, _changeset} = error} ->
        IO.inspect(error)
        answer(context, gettext("Não foi possível criar o seu cadastro. :("))

      {:location, {:error, _changeset}} ->
        answer(context, gettext("Não foi possível salvar a sua localização. :("))
    end
  end
end
