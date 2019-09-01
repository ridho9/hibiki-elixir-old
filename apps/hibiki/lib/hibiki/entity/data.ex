defmodule Hibiki.Entity.Data do
  use GenServer
  require Logger

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @spec set(struct, any, any) :: :ok | {:error, any}
  def set(entity, key, value) do
    GenServer.call(__MODULE__, {:set, {entity, key, value}})
  end

  @spec get(struct, any) :: any
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
