defmodule Easypodcasts.Telegram.Bot do
  use Telegram.Bot
  alias Easypodcasts.Channels

  @impl Telegram.Bot
  def handle_update(
        %{
          "message" => %{
            "text" => "/start",
            "chat" => %{"id" => chat_id, "type" => "private"}
          }
        },
        token
      ) do
    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      parse_mode: "Markdown",
      text: """
      Bienvenido a EasyPodcasts, estos son los comandos disponibles:

      `/nuevos_podcasts si | no` para subscribirte o eliminar la subscripción a nuevos podcasts.
      """
    )
  end

  @impl Telegram.Bot
  def handle_update(
        %{
          "message" => %{
            "text" => "/help",
            "chat" => %{"id" => chat_id}
          }
        },
        token
      ) do
    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      parse_mode: "Markdown",
      text: """
      Comandos: 

      `/nuevos_podcasts si | no` para subscribirte o eliminar la subscripción a nuevos podcasts.
      """
    )
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/nuevos_podcasts",
            "chat" => %{"id" => chat_id, "type" => chat_type},
            "from" => %{"id" => from_id}
          }
        },
        token
      ) do
    message =
      case chat_type do
        "private" ->
          message_is_subscribed_new_podcasts(chat_id)

        _ ->
          if is_admin(chat_id, from_id, token) do
            message_is_subscribed_new_podcasts(chat_id)
          else
            "No tiene permiso para realizar esta acción"
          end
      end

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      parse_mode: "Markdown",
      text: message
    )
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/nuevos_podcasts " <> arg,
            "chat" => %{"id" => chat_id, "type" => chat_type},
            "from" => %{"id" => from_id}
          }
        },
        token
      ) do
    message =
      case arg do
        "si" ->
          if chat_type == "private" or is_admin(chat_id, from_id, token) do
            subscribe_new_podcasts(chat_id)
          else
            "No tiene permiso para realizar esta acción"
          end

        "no" ->
          if chat_type == "private" or is_admin(chat_id, from_id, token) do
            unsubcribe_new_podcasts(chat_id)
          else
            "No tiene permiso para realizar esta acción"
          end

        _ ->
          """
          Opción inválida, usa las opciones `si`, `no` o consulta la ayuda con  `/help`
          """
      end

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      parse_mode: "Markdown",
      text: message
    )
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/buscar " <> search_string,
            "chat" => %{"id" => chat_id, "type" => chat_type},
            "from" => %{"id" => from_id}
          }
        },
        token
      ) do
    if chat_type == "private" or is_admin(chat_id, from_id, token) do
      case Channels.list_channels(%{"search" => search_string}, false) do
        [] ->
          Telegram.Api.request(token, "sendMessage",
            chat_id: chat_id,
            parse_mode: "Markdown",
            text: "No se encontró ningún podcast"
          )

        channels ->
          subscription = Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id)
          channel_ids = if subscription, do: Enum.map(subscription.channels, & &1.id), else: []

          Enum.each(channels, fn channel ->
            button =
              if channel.id in channel_ids do
                %{
                  text: "Cancelar suscripción",
                  callback_data: "unsubscribe #{channel.id}"
                }
              else
                %{text: "Suscribir", callback_data: "subscribe #{channel.id}"}
              end

            Telegram.Api.request(token, "sendMessage",
              chat_id: chat_id,
              text: "https://easypodcasts.live/#{Easypodcasts.Helpers.Utils.slugify(channel)}",
              reply_markup:
                {:json,
                 %{
                   inline_keyboard: [
                     [button]
                   ]
                 }}
            )
          end)
      end
    else
      Telegram.Api.request(token, "sendMessage",
        chat_id: chat_id,
        parse_mode: "Markdown",
        text: "No tiene permiso para realizar esta acción"
      )
    end
  end

  def handle_update(
        %{
          "callback_query" => %{
            "data" => "subscribe " <> podcast_id,
            "from" => %{"id" => from_id},
            "message" => %{
              "message_id" => message_id,
              "chat" => %{"id" => chat_id, "type" => chat_type},
              "text" => text
            }
          }
        },
        token
      ) do
    case chat_type do
      "private" ->
        subscribe_to_podcast(chat_id, podcast_id, text, message_id, token)

      _ ->
        if is_admin(chat_id, from_id, token) do
          subscribe_to_podcast(chat_id, podcast_id, text, message_id, token)
        else
          Telegram.Api.request(token, "sendMessage",
            chat_id: chat_id,
            parse_mode: "Markdown",
            text: "No tiene permiso para realizar esta acción"
          )
        end
    end
  end

  def handle_update(
        %{
          "callback_query" => %{
            "data" => "unsubscribe " <> podcast_id,
            "from" => %{"id" => from_id},
            "message" => %{
              "message_id" => message_id,
              "chat" => %{"id" => chat_id, "type" => chat_type},
              "text" => text
            }
          }
        },
        token
      ) do
    case chat_type do
      "private" ->
        unsubscribe_from_podcast(chat_id, podcast_id, text, message_id, token)

      _ ->
        if is_admin(chat_id, from_id, token) do
          unsubscribe_from_podcast(chat_id, podcast_id, text, message_id, token)
        else
          Telegram.Api.request(token, "sendMessage",
            chat_id: chat_id,
            parse_mode: "Markdown",
            text: "No tiene permiso para realizar esta acción"
          )
        end
    end
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/suscripciones",
            "chat" => %{"id" => chat_id}
          }
        },
        token
      ) do
    case Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id) do
      nil ->
        Telegram.Api.request(token, "sendMessage",
          chat_id: chat_id,
          parse_mode: "Markdown",
          text: "No está suscrito a ningún podcast"
        )

      %Easypodcasts.Telegram.Subscription{} = subscription ->
        case subscription.channels do
          [] ->
            Telegram.Api.request(token, "sendMessage",
              chat_id: chat_id,
              parse_mode: "Markdown",
              text: "No está suscrito a ningún podcast"
            )

          [_ | _] ->
            Enum.each(subscription.channels, fn channel ->
              Telegram.Api.request(token, "sendMessage",
                chat_id: chat_id,
                text: "https://easypodcasts.live/#{Easypodcasts.Helpers.Utils.slugify(channel)}",
                reply_markup:
                  {:json,
                   %{
                     inline_keyboard: [
                       [
                         %{
                           text: "Cancelar suscripción",
                           callback_data: "unsubscribe #{channel.id}"
                         }
                       ]
                     ]
                   }}
              )
            end)
        end
    end
  end

  def handle_update(_, _) do
    # Telegram.Api.request(token, "sendMessage",
    #   chat_id: chat_id,
    #   parse_mode: "Markdown",
    #   text: """
    #   Comando desconocido.
    #
    #   Consulte la ayuda con el comando `/help`.
    #   """
    # )
  end

  defp is_admin(chat_id, user_id, token) do
    user_id in (token
                |> Telegram.Api.request("getChatAdministrators", chat_id: chat_id)
                |> then(fn {:ok, admins} -> admins end)
                |> Enum.map(fn admin -> admin["user"]["id"] end))
  end

  defp message_is_subscribed_new_podcasts(chat_id) do
    if Easypodcasts.Telegram.is_subscribed_new_podcasts(chat_id) do
      """
      Estás suscrito a nuevos podcasts. Recibirás un mensaje cuando se agreguen nuevos podcasts a EasyPodcasts.

      Usa `/nuevos_podcasts no` para eliminar la suscripción.
      """
    else
      """
      No estás suscrito a nuevos podcasts.

      Usa `/nuevos_podcasts si` para suscribirte.
      """
    end
  end

  defp subscribe_new_podcasts(chat_id) do
    case Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id) do
      nil ->
        Easypodcasts.Telegram.create_subscription(%{
          chat_id: Integer.to_string(chat_id),
          new_podcasts: true
        })

      %Easypodcasts.Telegram.Subscription{} = subscription ->
        Easypodcasts.Telegram.update_subscription(subscription, %{new_podcasts: true})
    end

    """
    Estás suscrito a nuevos podcasts. Recibirás un mensaje cuando se agreguen nuevos podcasts a EasyPodcasts.

    Usa `/nuevos_podcasts no` para eliminar la suscripción.
    """
  end

  defp subscribe_to_podcast(chat_id, channel_id, text, message_id, token) do
    channel = Easypodcasts.Channels.get_channel(channel_id)

    case Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id) do
      nil ->
        {:ok, subscription} =
          Easypodcasts.Telegram.create_subscription(%{
            chat_id: Integer.to_string(chat_id),
            new_podcasts: false
          })

        subscription = Easypodcasts.Repo.preload(subscription, :channels)
        Easypodcasts.Telegram.update_podcast_subscription(subscription, %{channel: channel})

      %Easypodcasts.Telegram.Subscription{} = subscription ->
        Easypodcasts.Telegram.update_podcast_subscription(subscription, %{channel: channel})
    end

    Telegram.Api.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup:
        {:json,
         %{
           inline_keyboard: [
             [
               %{
                 text: "Cancelar suscripción",
                 callback_data: "unsubscribe #{channel_id}"
               }
             ]
           ]
         }}
    )
  end

  defp unsubscribe_from_podcast(chat_id, channel_id, text, message_id, token) do
    case Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id) do
      %Easypodcasts.Telegram.Subscription{} = subscription ->
        Easypodcasts.Telegram.delete_channel_subscription(subscription.id, channel_id)

        Telegram.Api.request(token, "editMessageText",
          chat_id: chat_id,
          message_id: message_id,
          text: text,
          reply_markup:
            {:json,
             %{
               inline_keyboard: [
                 [
                   %{
                     text: "Suscribir",
                     callback_data: "subscribe #{channel_id}"
                   }
                 ]
               ]
             }}
        )

      _ ->
        nil
    end
  end

  defp unsubcribe_new_podcasts(chat_id) do
    case Easypodcasts.Telegram.get_subscription_by_chat_id(chat_id) do
      nil ->
        Easypodcasts.Telegram.create_subscription(%{chat_id: chat_id})

      %Easypodcasts.Telegram.Subscription{} = subscription ->
        Easypodcasts.Telegram.update_subscription(subscription, %{new_podcasts: false})
    end

    """
    Se ha eliminado tu suscripción a nuevos podcasts.

    Usa `/nuevos_podcasts si` para suscribirte.
    """
  end

  def notify_new_podcast(podcast) do
    token = Application.get_env(:easypodcasts, Easypodcasts)[:telegram_token]

    Easypodcasts.Telegram.list_subscribed_new_podcasts()
    |> Enum.chunk_every(20)
    |> Enum.each(fn subscribed_chats ->
      Enum.each(
        subscribed_chats,
        &Telegram.Api.request(token, "sendMessage",
          chat_id: &1,
          text: """
          ¡Hay un nuevo podcast en EasyPodcasts!

          #{podcast.title}

          #{podcast.description}

          https://easypodcasts.live/#{Easypodcasts.Helpers.Utils.slugify(podcast)}
          """
        )
      )

      # try to avoid telegram api limits
      Process.sleep(5000)
    end)
  end

  def notify_new_episode(episode) do
    token = Application.get_env(:easypodcasts, Easypodcasts)[:telegram_token]

    episode = Easypodcasts.Repo.preload(episode, channel: :subscriptions)

    episode.channel.subscriptions
    |> Enum.chunk_every(20)
    |> Enum.each(fn subscribed_chats ->
      Enum.each(
        subscribed_chats,
        &Telegram.Api.request(token, "sendMessage",
          chat_id: &1.chat_id,
          text: """
          Nuevo episodio de #{episode.channel.title}

          https://easypodcasts.live/#{Easypodcasts.Helpers.Utils.slugify(episode.channel)}/#{Easypodcasts.Helpers.Utils.slugify(episode)}
          """
        )
      )

      # try to avoid telegram api limits
      Process.sleep(5000)
    end)

    %{
      "callback_query" => %{
        "chat_instance" => "5681489303743736298",
        "data" => "subscribe 30",
        "from" => %{
          "first_name" => "Guillermo",
          "id" => 533_425_919,
          "is_bot" => false,
          "language_code" => "en",
          "last_name" => "Roig",
          "username" => "groig"
        },
        "id" => "2291046877294340723",
        "message" => %{
          "chat" => %{
            "id" => -1_001_443_803_615,
            "title" => "elixircuba",
            "type" => "supergroup",
            "username" => "elixircuba"
          },
          "date" => 1_672_796_088,
          "entities" => [%{"length" => 52, "offset" => 0, "type" => "url"}],
          "from" => %{
            "first_name" => "EasyPodcastsDev",
            "id" => 5_887_455_401,
            "is_bot" => true,
            "username" => "EasyPodcastsDevBot"
          },
          "message_id" => 19,
          "reply_markup" => %{
            "inline_keyboard" => [[%{"callback_data" => "subscribe 30", "text" => "Suscribir"}]]
          },
          "text" => "https://easypodcasts.live/30-the-real-python-podcast"
        }
      },
      "update_id" => 74_725_756
    }
  end
end
