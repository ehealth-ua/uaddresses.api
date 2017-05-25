defmodule Uaddresses.Workers.ProcessFile do
  @moduledoc false

  alias Uaddresses.Streets
  alias Uaddresses.Settlements
  alias Uaddresses.Regions
  alias Uaddresses.Districts

  def run do

    :ets.new(:regions_temp, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(:districts_temp, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(:settlements_temp, [:set, :public, :named_table, read_concurrency: true])

    "/Users/samorai/Desktop/houses.csv"
    |> File.stream!()
    |> Stream.chunk(1000)
    |> Enum.each(fn(chunk) ->
         chunk
         |> ExCsv.parse!(delimiter: ';')
         |> ExCsv.with_headings([:region, :district, :settlement, :postal_code, :street_name, :street_numbers])
         |> Enum.to_list
         |> Enum.each(&process_street/1)
       end)
  end

  defp process_street(street) do
    if street.district != "Район" do
      street
      |> Map.put(:street_numbers, String.split(Map.get(street, :street_numbers), ","))
      |> Map.get(:street_numbers)
      |> Enum.each(fn street_number ->
        region_id = get_region_id(street.region)
        district_id = get_district_id(street.district, region_id)
        settlement_id = get_settlement_id(street.settlement, district_id, region_id)
        {street_name, street_type} = get_street_name_and_type(street.street_name)

        %{
          region_id: region_id,
          district_id: district_id,
          settlement_id: settlement_id,
          postal_code: street.postal_code,
          street_number: street_number,
          street_name: street_name,
          street_type: street_type
        }
        |> Streets.create_street()
      end)
    end
  end

  def get_region_id(region_name) do
    region_data = :regions_temp
    |> :ets.match_object({:"$1", region_name})

    cond do
      Kernel.length(region_data) == 0 ->
        region_id = create_region(region_name)
        :ets.insert(:regions_temp, {region_id, region_name})
        region_id
      Kernel.length(region_data) == 1 ->
        [{region_id, _region_name}| _tail] = region_data
        region_id
      true -> nil
    end
  end

  def get_district_id(district_name, region_id) do
    district_data = :districts_temp
    |> :ets.match_object({:"$1", district_name, region_id})

    cond do
      Kernel.length(district_data) == 0 ->
        district_id = create_district(district_name, region_id)
        :ets.insert(:districts_temp, {district_id, district_name, region_id})
        district_id
      Kernel.length(district_data) == 1 ->
        [{district_id, _district_name, _region_id}| _tail] = district_data
        district_id
      true -> nil
    end
  end

  def get_settlement_id(settlement_name, district_id, region_id) do
    settlements_data = :settlements_temp
    |> :ets.match_object({:"$1", settlement_name, district_id, region_id})

    cond do
      Kernel.length(settlements_data) == 0 ->
        settlement_id = create_settlement(settlement_name, district_id, region_id)
          :ets.insert(:settlements_temp, {settlement_id, settlement_name, district_id, region_id})
        settlement_id
      Kernel.length(settlements_data) == 1 ->
        [{settlement_id, _settlement_name, _district_id, _region_id}| _tail] = settlements_data
        settlement_id
      true -> nil
    end
  end

  def create_settlement(settlement_name, district_id, region_id) do
    {:ok, %Settlements.Settlement{id: id}} =
      %{name: settlement_name, district_id: district_id, region_id: region_id, mountain_group: false}
      |> Settlements.create_settlement()
    id
  end

  def create_region(name) do
    {:ok, %Regions.Region{id: region_id}} = Regions.create_region(%{name: name})
    region_id
  end

  def create_district(district_name, region_id) do
    {:ok, %Districts.District{id: district_id}} =
      %{name: district_name, region_id: region_id}
      |> Districts.create_district()
    district_id
  end

  def get_street_name_and_type(name) do
    cond do
      String.starts_with?(name, "вул.") -> {String.trim_leading(name, "вул. "), "вулиця"}
      String.starts_with?(name, "пров.") -> {String.trim_leading(name, "пров. "), "провулок"}
      String.starts_with?(name, "пл.") -> {String.trim_leading(name, "пл. "), "площа"}
      String.starts_with?(name, "просп.") -> {String.trim_leading(name, "просп. "), "проспект"}
      String.starts_with?(name, "проїзд") -> {String.trim_leading(name, "проїзд "), "проїзд"}
      String.starts_with?(name, "хутір") -> {String.trim_leading(name, "хутір "), "хутір"}
      String.starts_with?(name, "тупік") -> {String.trim_leading(name, "тупік "), "тупік"}
      String.starts_with?(name, "узвіз") -> {String.trim_leading(name, "узвіз "), "узвіз"}
      String.starts_with?(name, "парк") -> {String.trim_leading(name, "парк "), "парк"}
      String.starts_with?(name, "жилий масив") -> {String.trim_leading(name, "жилий масив "), "жилий масив"}
      String.starts_with?(name, "шосе") -> {String.trim_leading(name, "шосе "), "шосе"}
      String.starts_with?(name, "бульв.") -> {String.trim_leading(name, "бульв. "), "бульвар"}
      String.starts_with?(name, "м-р") -> {String.trim_leading(name, "м-р "), "мікрорайон"}
      String.starts_with?(name, "майдан") -> {String.trim_leading(name, "майдан "), "майдан"}
      String.starts_with?(name, "спуск") -> {String.trim_leading(name, "спуск "), "спуск"}
      String.starts_with?(name, "острів") -> {String.trim_leading(name, "острів "), "острів"}
      String.starts_with?(name, "містечко") -> {String.trim_leading(name, "містечко "), "містечко"}
      String.starts_with?(name, "завулок") -> {String.trim_leading(name, "завулок "), "завулок"}
      String.starts_with?(name, "лінія") -> {String.trim_leading(name, "лінія "), "лінія"}
      String.starts_with?(name, "кв-л") -> {String.trim_leading(name, "кв-л "), "квартал"}
      String.starts_with?(name, "в’їзд") -> {String.trim_leading(name, "в’їзд "), "в’їзд"}
      String.starts_with?(name, "набережна") -> {String.trim_leading(name, "набережна "), "набережна"}
      String.starts_with?(name, "шлях") -> {String.trim_leading(name, "шлях "), "шлях"}
      String.starts_with?(name, "алея") -> {String.trim_leading(name, "алея "), "алея"}
      String.starts_with?(name, "урочище") -> {String.trim_leading(name, "урочище "), "урочище"}
      String.starts_with?(name, "дорога") -> {String.trim_leading(name, "дорога "), "дорога"}
      String.starts_with?(name, "вулиця відсутня") -> {String.trim_leading(name, "вулиця відсутня "), "вулиця відсутня"}
      String.starts_with?(name, "селище") -> {String.trim_leading(name, "селище "), "селище"}
    end
  end

  def get_street_name(name) do
    cond do
      String.starts_with?(name, "вул.") -> String.trim_leading(name, "вул. ")
      String.starts_with?(name, "пров.") -> String.trim_leading(name, "пров. ")
      String.starts_with?(name, "пл.") -> String.trim_leading(name, "пл. ")
      String.starts_with?(name, "просп.") -> String.trim_leading(name, "просп. ")
      String.starts_with?(name, "проїзд") -> String.trim_leading(name, "проїзд ")
      String.starts_with?(name, "хутір") -> String.trim_leading(name, "хутір ")
      String.starts_with?(name, "тупік") -> String.trim_leading(name, "тупік ")
      String.starts_with?(name, "узвіз") -> String.trim_leading(name, "узвіз ")
      String.starts_with?(name, "парк") -> String.trim_leading(name, "парк ")
      String.starts_with?(name, "жилий масив") -> String.trim_leading(name, "жилий масив ")
      String.starts_with?(name, "шосе") -> String.trim_leading(name, "шосе ")
      String.starts_with?(name, "бульв.") -> String.trim_leading(name, "бульв. ")
      String.starts_with?(name, "м-р") -> String.trim_leading(name, "м-р ")
      String.starts_with?(name, "майдан") -> String.trim_leading(name, "майдан ")
      String.starts_with?(name, "спуск") -> String.trim_leading(name, "спуск ")
      String.starts_with?(name, "острів") -> String.trim_leading(name, "острів ")
      String.starts_with?(name, "містечко") -> String.trim_leading(name, "містечко ")
      String.starts_with?(name, "завулок") -> String.trim_leading(name, "завулок ")
      String.starts_with?(name, "лінія") -> String.trim_leading(name, "лінія ")
      String.starts_with?(name, "кв-л") -> String.trim_leading(name, "кв-л ")
      String.starts_with?(name, "в’їзд") -> String.trim_leading(name, "в’їзд ")
      String.starts_with?(name, "набережна") -> String.trim_leading(name, "набережна ")
      String.starts_with?(name, "шлях") -> String.trim_leading(name, "шлях ")
      String.starts_with?(name, "алея") -> String.trim_leading(name, "алея ")
      String.starts_with?(name, "урочище") -> String.trim_leading(name, "урочище ")
      String.starts_with?(name, "дорога") -> String.trim_leading(name, "дорога ")
      String.starts_with?(name, "вулиця відсутня") -> String.trim_leading(name, "вулиця відсутня ")
      String.starts_with?(name, "селище") -> String.trim_leading(name, "селище ")
    end
  end

  def get_street_type(name) do
    cond do
      String.starts_with?(name, "вул.") -> "вулиця"
      String.starts_with?(name, "пров.") -> "провулок"
      String.starts_with?(name, "пл.") -> "площа"
      String.starts_with?(name, "просп.") -> "проспект"
      String.starts_with?(name, "проїзд") -> "проїзд"
      String.starts_with?(name, "хутір") -> "хутір"
      String.starts_with?(name, "тупік") -> "тупік"
      String.starts_with?(name, "узвіз") -> "узвіз"
      String.starts_with?(name, "парк") -> "парк"
      String.starts_with?(name, "шосе") -> "шосе"
      String.starts_with?(name, "жилий масив") -> "жилий масив"
      String.starts_with?(name, "м-р") -> "мікрорайон"
      String.starts_with?(name, "бульв.") -> "бульвар"
      String.starts_with?(name, "майдан") -> "майдан"
      String.starts_with?(name, "спуск") -> "спуск"
      String.starts_with?(name, "острів") -> "острів"
      String.starts_with?(name, "містечко") -> "містечко"
      String.starts_with?(name, "завулок") -> "завулок"
      String.starts_with?(name, "лінія") -> "лінія"
      String.starts_with?(name, "кв-л") -> "квартал"
      String.starts_with?(name, "в’їзд") -> "в’їзд"
      String.starts_with?(name, "набережна") -> "набережна"
      String.starts_with?(name, "шлях") -> "шлях"
      String.starts_with?(name, "алея") -> "алея"
      String.starts_with?(name, "урочище") -> "урочище"
      String.starts_with?(name, "дорога") -> "дорога"
      String.starts_with?(name, "вулиця відсутня") -> "вулиця відсутня"
      String.starts_with?(name, "селище") -> "селище"
    end
  end
end
