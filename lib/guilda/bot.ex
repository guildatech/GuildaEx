defmodule Guilda.Bot do
  @moduledoc """
  Our bot used to store the user's location.
  """
  @bot :guilda

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  import GuildaWeb.Gettext

  require Logger

  alias Guilda.Accounts
  alias Guilda.Accounts.User

  command("start")
  command("help", description: "Mostra os comandos do bot.")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot, do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Olá!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(
      context,
      """
      Eu sou o bot da @guildatech!

      Por enquanto eu não respondo a nenhum comando, mas você pode me enviar sua localização para aparecer no nosso mapa de participantes!

      Para isso, basta apenas me enviar sua localização usando o seu celular.

      Para ver quem já compartilhou a localização acesse https://guildatech.com/members.
      """
    )
  end

  def handle({:location, %{latitude: lat, longitude: lng}}, context) do
    from = context.update.message.from

    with {:user, %User{} = user} <- {:user, Accounts.get_user_by_telegram_id(Kernel.to_string(from.id))},
         {:location, {:ok, _user}} <- {:location, Accounts.set_lng_lat(user, lng, lat)} do
      answer(
        context,
        gettext("Your location has been saved successfully! See the map at https://guildatech.com/members.")
      )
    else
      {:user, nil} ->
        answer(
          context,
          gettext(
            "You don't have an account yet. Please register at https://guildatech.com/users/register, confirm your email address and link your Telegram account."
          )
        )

      {:location, {:error, _changeset}} ->
        answer(context, gettext("Unable to save your location."))
    end
  end
end
