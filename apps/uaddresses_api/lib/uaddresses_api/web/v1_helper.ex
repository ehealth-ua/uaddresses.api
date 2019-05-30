defmodule Uaddresses.Web.V1Helper do
  @moduledoc false

  def params_to_v1(params) do
    params
    |> replace_key("region", "area")
    |> replace_key("region_id", "area_id")
    |> replace_key("district_id", "region_id")
    |> replace_key("district", "region")
  end

  defp replace_key(%{} = map, key, new_key) do
    if Map.has_key?(map, key) do
      {value, updated_map} = pop_in(map, [key])

      Map.put(updated_map, new_key, value)
    else
      map
    end
  end
end
