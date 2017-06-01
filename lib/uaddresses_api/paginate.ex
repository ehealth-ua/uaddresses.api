defmodule Uaddresses.Paginate do
  @moduledoc """
  Search implementation
  """

  defmacro __using__(_) do
    quote  do

      alias Uaddresses.Repo

      def paginate(entity, query_params, default_limit \\ 10) do
        limit =
          query_params
          |> Map.get("limit", default_limit)
          |> to_integer()

        cursors = %Ecto.Paging.Cursors{
          starting_after: Map.get(query_params, "starting_after"),
          ending_before: Map.get(query_params, "ending_before")
        }

        Repo.page(entity, %Ecto.Paging{limit: limit, cursors: cursors})
      end

      def to_integer(value) when is_binary(value), do: String.to_integer(value)
      def to_integer(value), do: value
    end
  end
end
