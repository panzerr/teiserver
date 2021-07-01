defmodule Teiserver.Telemetry do
  import Telemetry.Metrics

  import Ecto.Query, warn: false
  alias Central.Helpers.QueryHelpers
  alias Central.Repo

  alias Teiserver.Telemetry.TelemetryServer
  alias Teiserver.Telemetry.TelemetryMinuteLog
  alias Teiserver.Telemetry.TelemetryMinuteLogLib
  alias Teiserver.Telemetry.TelemetryDayLog
  alias Teiserver.Telemetry.TelemetryDayLogLib

  alias Teiserver.Telemetry.{Event, ClientEvent, ClientProperty, UnauthProperty, BattleEvent}

  # Telemetry todo lists
  # TODO: Beherith: clients logged in, clients ingame, clients singpleplayer, clients afk, clients that are bots are not clients
  # TODO: Matchmaking telemetry
  # TODO: In battle telemetry
  # TODO: Client event telemetry

  def get_state_and_reset() do
    GenServer.call(TelemetryServer, :get_state_and_reset)
  end

  @spec metrics() :: List.t()
  def metrics() do
    [
      last_value("teiserver.client.total"),
      last_value("teiserver.client.menu"),
      last_value("teiserver.client.battle"),

      last_value("teiserver.battle.total"),
      last_value("teiserver.battle.lobby"),
      last_value("teiserver.battle.in_progress")
    ]
  end

  @spec periodic_measurements() :: List.t()
  def periodic_measurements() do
    [
      # {Teiserver.Telemetry, :measure_users, []},
      # {:process_info,
      #   event: [:teiserver, :ts],
      #   name: Teiserver.Telemetry.TelemetryServer,
      #   keys: [:message_queue_len, :memory]}
    ]
  end

  # Telemetry logs - Database

  defp telemetry_minute_log_query(args) do
    telemetry_minute_log_query(nil, args)
  end

  defp telemetry_minute_log_query(timestamp, args) do
    TelemetryMinuteLogLib.get_telemetry_minute_logs()
    |> TelemetryMinuteLogLib.search(%{timestamp: timestamp})
    |> TelemetryMinuteLogLib.search(args[:search])
    |> TelemetryMinuteLogLib.order_by(args[:order])
    |> QueryHelpers.select(args[:select])
  end

  @doc """
  Returns the list of logging_logs.

  ## Examples

      iex> list_logging_logs()
      [%TelemetryMinute{}, ...]

  """
  def list_telemetry_minute_logs(args \\ []) do
    telemetry_minute_log_query(args)
    |> QueryHelpers.limit_query(args[:limit] || 50)
    |> Repo.all()
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the TelemetryMinute does not exist.

  ## Examples

      iex> get_log!(123)
      %TelemetryMinute{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_telemetry_minute_log(timestamp) when not is_list(timestamp) do
    telemetry_minute_log_query(timestamp, [])
    |> Repo.one()
  end

  def get_telemetry_minute_log(args) do
    telemetry_minute_log_query(nil, args)
    |> Repo.one()
  end

  def get_telemetry_minute_log(timestamp, args) do
    telemetry_minute_log_query(timestamp, args)
    |> Repo.one()
  end

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %TelemetryMinute{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_telemetry_minute_log(attrs \\ %{}) do
    %TelemetryMinuteLog{}
    |> TelemetryMinuteLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %TelemetryMinuteLog{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_telemetry_minute_log(%TelemetryMinuteLog{} = log, attrs) do
    log
    |> TelemetryMinuteLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TelemetryMinuteLog.

  ## Examples

      iex> delete_log(log)
      {:ok, %TelemetryMinuteLog{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_telemetry_minute_log(%TelemetryMinuteLog{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{source: %TelemetryMinuteLog{}}

  """
  def change_telemetry_minute_log(%TelemetryMinuteLog{} = log) do
    TelemetryMinuteLog.changeset(log, %{})
  end

  # Day logs


  defp telemetry_day_log_query(args) do
    telemetry_day_log_query(nil, args)
  end

  defp telemetry_day_log_query(date, args) do
    TelemetryDayLogLib.get_telemetry_day_logs()
    |> TelemetryDayLogLib.search(%{date: date})
    |> TelemetryDayLogLib.search(args[:search])
    |> TelemetryDayLogLib.order_by(args[:order])
    |> QueryHelpers.select(args[:select])
  end

  @doc """
  Returns the list of logging_logs.

  ## Examples

      iex> list_logging_logs()
      [%TelemetryDayLog{}, ...]

  """
  def list_telemetry_day_logs(args \\ []) do
    telemetry_day_log_query(args)
    |> QueryHelpers.limit_query(50)
    |> Repo.all()
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the TelemetryDayLog does not exist.

  ## Examples

      iex> get_log!(123)
      %TelemetryDayLog{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_telemetry_day_log(date) when not is_list(date) do
    telemetry_day_log_query(date, [])
    |> Repo.one()
  end

  def get_telemetry_day_log(args) do
    telemetry_day_log_query(nil, args)
    |> Repo.one()
  end

  def get_telemetry_day_log(date, args) do
    telemetry_day_log_query(date, args)
    |> Repo.one()
  end

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %TelemetryDayLog{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_telemetry_day_log(attrs \\ %{}) do
    %TelemetryDayLog{}
    |> TelemetryDayLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %TelemetryDayLog{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_telemetry_day_log(%TelemetryDayLog{} = log, attrs) do
    log
    |> TelemetryDayLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TelemetryDayLog.

  ## Examples

      iex> delete_log(log)
      {:ok, %TelemetryDayLog{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_telemetry_day_log(%TelemetryDayLog{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{source: %TelemetryDayLog{}}

  """
  def change_telemetry_day_log(%TelemetryDayLog{} = log) do
    TelemetryDayLog.changeset(log, %{})
  end

  @spec get_first_telemetry_minute_datetime() :: DateTime.t() | nil
  def get_first_telemetry_minute_datetime() do
    query =
      from telemetry_logs in TelemetryMinuteLog,
        order_by: [asc: telemetry_logs.timestamp],
        select: telemetry_logs.timestamp,
        limit: 1

    Repo.one(query)
  end

  @spec get_last_telemtry_day_log() :: Date.t() | nil
  def get_last_telemtry_day_log() do
    query =
      from telemetry_logs in TelemetryDayLog,
        order_by: [desc: telemetry_logs.date],
        select: telemetry_logs.date,
        limit: 1

    Repo.one(query)
  end

  def user_lookup(logs) do
    user_ids =
      logs
      |> Enum.map(fn l -> Map.keys(l.data["minutes_per_user"]["total"]) end)
      |> List.flatten()
      |> Enum.uniq()

    query =
      from users in Central.Account.User,
        where: users.id in ^user_ids

    query
    |> Repo.all()
    |> Enum.map(fn u -> {u.id, u} end)
    |> Map.new()
  end

  def get_todays_log() do
    last_time = ConCache.get(:application_metadata_cache, "teiserver_day_metrics_today_last_time")
    recache = cond do
      last_time == nil -> true
      Timex.compare(Timex.now() |> Timex.shift(minutes: -15), last_time) == 1 -> true
      true -> false
    end

    if recache do
      data = Teiserver.Tasks.PersistTelemetryDayTask.today_so_far()
      ConCache.put(:application_metadata_cache, "teiserver_day_metrics_today_cache", data)
      ConCache.put(:application_metadata_cache, "teiserver_day_metrics_today_last_time", Timex.now())
      data
    else
      ConCache.get(:application_metadata_cache, "teiserver_day_metrics_today_cache")
    end
  end

  def export_logs(logs) do
    logs
  end

  def list_unauth_properties(args \\ []) do
    query = from properties in UnauthProperty,
      join: events in assoc(properties, :event),
      preload: [event: events]
    Repo.all(query)
  end

  def list_client_properties(args \\ []) do
    query = from properties in ClientProperty,
      join: events in assoc(properties, :event),
      preload: [event: events]
    Repo.all(query)
  end

  def log_client_event(userid, event_name, value, hash) do
    event_id = get_or_add_event(event_name)
    %ClientEvent{}
      |> ClientEvent.changeset(%{
        event_id: event_id,
        user_id: userid,
        value: value,
        timestamp: Timex.now(),
        hash: hash
      })
      |> Repo.insert()
  end

  def update_client_property(nil, value_name, value, hash) do
    event_id = get_or_add_event(value_name)

    # Delete existing ones first
    query = from properties in UnauthProperty,
      where: properties.event_id == ^event_id
        and properties.hash == ^hash
    property = Repo.one(query)
    if property do
      Repo.delete(property)
    end

    %UnauthProperty{}
      |> UnauthProperty.changeset(%{
        event_id: event_id,
        value: value,
        last_updated: Timex.now(),
        hash: hash
      })
      |> Repo.insert()
  end

  def update_client_property(userid, value_name, value, hash) do
    event_id = get_or_add_event(value_name)

    # Delete existing ones first
    query = from properties in ClientProperty,
      where: properties.user_id == ^userid
        and properties.event_id == ^event_id
    property = Repo.one(query)
    if property do
      Repo.delete(property)
    end

    %ClientProperty{}
      |> ClientProperty.changeset(%{
        event_id: event_id,
        user_id: userid,
        value: value,
        last_updated: Timex.now()
      })
      |> Repo.insert()
  end

  def log_battle_event(userid, event_name, value, hash) do
    event_id = get_or_add_event(event_name)
    %BattleEvent{}
      |> BattleEvent.changeset(%{
        battle_id: 0,
        event_id: event_id,
        user_id: userid,
        value: value,
        timestamp: Timex.now()
      })
      |> Repo.insert()
  end

  def get_or_add_event(name) do
    case ConCache.get(:teiserver_telemetry_events, name) do
      nil ->
        {:ok, event} = %Event{}
          |> Event.changeset(%{name: name})
          |> Repo.insert()

        ConCache.put(:teiserver_telemetry_events, event.name, event.id)
        event.id
      event_id ->
        event_id
    end
  end

  def startup() do
    query = from events in Event

    Repo.all(query)
    |> Enum.map(fn event ->
      ConCache.put(:teiserver_telemetry_events, event.name, event.id)
    end)
  end
end
