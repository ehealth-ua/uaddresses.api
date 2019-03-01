defmodule Uaddresses.Search do
  @moduledoc """
  Search implementation
  """

  defmacro __using__(_) do
    quote do
      import Ecto.{Query, Changeset}, warn: false
      import Uaddresses.Filters.Base, only: [filter: 2]

      alias Uaddresses.Repo

      def set_attributes_option(%Ecto.Changeset{valid?: false} = changeset, _fields, _option), do: changeset

      def set_attributes_option(
            %Ecto.Changeset{valid?: true, changes: changes} = changeset,
            fields,
            option
          ) do
        Enum.reduce(changes, changeset, fn {key, value}, changeset ->
          case key in fields do
            true -> put_change(changeset, key, {value, option})
            _ -> changeset
          end
        end)
      end

      def search(%Ecto.Changeset{valid?: true, changes: changes}, search_params, entity) do
        q =
          entity
          |> get_search_query(changes)
          |> Repo.paginate(search_params)
      end

      def search(%Ecto.Changeset{valid?: false} = changeset, _search_params, _entity) do
        {:error, changeset}
      end

      def search(entity_schema, filter, order_by \\ [], cursor \\ nil)
          when is_list(filter) and is_atom(entity_schema) do
        entities =
          entity_schema
          |> filter(filter)
          |> order_by(^order_by)
          |> apply_cursor(cursor)
          |> Repo.all()

        {:ok, entities}
      end

      def apply_cursor(query, {offset, limit}), do: query |> offset(^offset) |> limit(^limit)
      def apply_cursor(query, _), do: query

      def get_search_query(entity, changes) when map_size(changes) > 0 do
        params = Enum.filter(changes, fn {key, value} -> !is_tuple(value) end)

        q = from(e in entity, where: ^params)

        Enum.reduce(changes, q, fn {key, val}, query ->
          case val do
            {value, :full_text} ->
              query
              |> where([r], fragment("? % ?", field(r, ^key), ^value))
              |> order_by([r], desc: fragment("similarity(?, ?)", field(r, ^key), ^value))

            {value, :like} ->
              where(
                query,
                [r],
                ilike(
                  fragment("lower(?)", field(r, ^key)),
                  ^("%" <> String.downcase(value) <> "%")
                )
              )

            {value, :intersect} ->
              where(query, [r], fragment("string_to_array(?, ' ') && ?", field(r, ^key), ^value))

            {value, :ignore_case} ->
              where(query, [r], fragment("lower(?)", field(r, ^key)) == ^String.downcase(value))

            _ ->
              query
          end
        end)
      end

      def get_search_query(entity, _changes), do: from(e in entity)

      defoverridable get_search_query: 2
    end
  end
end
