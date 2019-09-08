defmodule Hibiki.Entity.Data do
  use GenServer
  require Logger
  alias Hibiki.Entity.Data.Key

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @spec set(Hibiki.Entity.t(), Key.t(), any) :: :ok | {:error, any}
  def set(entity, key, value) do
    GenServer.call(__MODULE__, {:set, {entity, key, value}})
  end

  @spec get(Hibiki.Entity.t(), Key.t()) :: term | nil
  def get(entity, key) do
    GenServer.call(__MODULE__, {:get, {entity, key}})
  end

  ## Server Callback

  def init(args) do
    Logger.info("Initializing Hibiki.Entity.Data")

    table_name = args[:table_name] || :entity_data_dets
    {:ok, table} = :dets.open_file(table_name, type: :set)
    {:ok, {table}}
  end

  def handle_call({:set, {entity, key, value}}, _from, {table}) do
    dets_key = {entity.line_id, key}
    dets_value = value

    res = :dets.insert(table, {dets_key, dets_value})
    :dets.sync(table)
    {:reply, res, {table}}
  end

  def handle_call({:get, {entity, key}}, _from, {table}) do
    dets_key = {entity.line_id, key}

    case :dets.lookup(table, dets_key) do
      [] -> {:reply, nil, {table}}
      [{^dets_key, result}] -> {:reply, result, {table}}
    end
  end

  def terminate(_reason, {table}) do
    Logger.info("Terminating Hibiki.Entity.Data")
    :dets.close(table)
  end
end

defmodule Hibiki.Entity.Data.Key do
  @type t :: :last_image_id | :last_text_message

  def last_image_id, do: :last_image_id

  def last_text_message, do: :last_text_message
end
