defmodule Topology do
    import Math
    # find neighbors for full topology
    def neighbor_full(id, num_of_nodes) do
        neighbors = Enum.map(0..num_of_nodes - 1, fn(x) -> x end)
        # Enum.filter(neighbors, fn(x) -> id !== x end)
        neighbors
    end

    # find neighbors for 2D topology
    def neighbor_2D(id, num_of_nodes) do
        neighbors = []
        square_len = Math.sqrt(num_of_nodes) |> round       
        row_index = div(id, square_len)
        col_index = rem(id, square_len)
        if row_index - 1 >= 0 do
            neighbor_up = (row_index - 1) * square_len + col_index
            neighbors = [neighbor_up | neighbors]
        end
        
        if row_index + 1 <= square_len - 1 do
            neighbor_down = (row_index + 1) * square_len + col_index
            neighbors = [neighbor_down | neighbors]
        end

        if col_index - 1 >= 0 do
            neighbor_left = id - 1
            neighbors = [neighbor_left | neighbors]
        end

        if col_index + 1 <= square_len - 1 do
            neighbor_right = id + 1
            neighbors = [neighbor_right | neighbors]
        end
        neighbors
    end

    # find neighbors for line topology
    def neighbor_line(id, num_of_nodes) do
        neighbors = []
        cond do
            id + 1 == num_of_nodes ->
                neighbors = [id - 1 | neighbors]
            id == 0 ->
                neighbors = [id + 1 | neighbors]
            true ->
                neighbors = [id + 1 | neighbors]
                neighbors = [id - 1 | neighbors]         
        end
        neighbors
    end

    # find neighbors for imperfect 2D topology
    def neighbor_imp2D(id, num_of_nodes) do
        neighbors = neighbor_2D(id, num_of_nodes)
        random_neighbor = :rand.uniform(num_of_nodes) - 1
        neighbors = [random_neighbor | neighbors]
    end
end