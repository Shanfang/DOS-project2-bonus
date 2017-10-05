defmodule App do
    def main(args) do
        #num_of_nodes = Enum.at(args, 0) |> String.to_integer
        num_of_nodes = Enum.at(args, 0)
        num_of_nodes = String.to_integer(num_of_nodes)   
        topology = Enum.at(args, 1)
        algorithm = Enum.at(args, 2)       
        loop(num_of_nodes, topology, algorithm, 1)
    end

    def loop(num_of_nodes, topology, algorithm, n) when n > 0 do            

        # for 2D based topology, round up num_of_nodes to a perfect square
        if topology == "2D" || topology == "imp2D" do           
            num_of_nodes = :math.sqrt(num_of_nodes) |> Float.ceil |> :math.pow(2) |>trunc
        end

        IO.puts "starting coordinator..."
        Coordinator.start_link
        Coordinator.initialize_actor_system(:coordinator, num_of_nodes, topology, algorithm)        
        loop(num_of_nodes, topology, algorithm, n - 1)
    end

    def loop(num_of_nodes, topology, algorithm, n) do
        :timer.sleep 1000
        loop(num_of_nodes, topology, algorithm, n)
    end
    
    #def round_up(num) do
    #    num = :math.sqrt(num) |> Float.ceil |> :math.pow(2) 
    #    num       
    #end
end