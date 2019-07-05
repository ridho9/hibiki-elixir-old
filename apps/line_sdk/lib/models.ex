defmodule LineSDK.Models do
  @moduledoc """
  Types used in Line Messaging API

  ## Reference
  https://developers.line.biz/en/reference/messaging-api/
  """

  defmodule TextMessage do
    defstruct text: nil, id: nil
    @type t :: %TextMessage{text: binary, id: binary}
  end

  defmodule Source do
    defmodule User do
      defstruct user_id: nil
      @type t :: %User{user_id: binary}
    end

    defmodule Group do
      defstruct user_id: nil, group_id: nil
      @type t :: %Group{user_id: binary, group_id: binary}
    end

    defmodule Room do
      defstruct user_id: nil, room_id: nil
      @type t :: %Room{user_id: binary, room_id: binary}
    end

    @type t :: User.t() | Group.t() | Room.t()
  end

  defmodule MessageEvent do
    defstruct reply_token: nil,
              source: nil,
              timestamp: nil,
              message: nil

    @type message :: TextMessage.t()

    @type t :: %MessageEvent{
            reply_token: binary,
            source: Source.t(),
            timestamp: number,
            message: MessageEvent.message()
          }
  end

  defmodule WebhookEvent do
    defstruct destination: nil,
              events: nil

    @type t :: %WebhookEvent{
            destination: binary,
            events: [event()]
          }

    @type event :: MessageEvent.t()
  end
end
