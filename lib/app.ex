defmodule App do
    def main(args) do
        num_of_nodes = Enum.at(args, 0)
        num_of_nodes = String.to_integer(num_of_nodes)   
        topology = Enum.at(args, 1)
        algorithm = Enum.at(args, 2)  
        failure_num = Enum.at(args, 3) 
        failure_num = String.to_integer(failure_num)    
        loop(num_of_nodes, topology, algorithm, failure_num, 1)
    end

    def loop(num_of_nodes, topology, algorithm, failure_num, n) when n > 0 do            

        # for 2D based topology, round up num_of_nodes to a perfect square
        if topology == "2D" || topology == "imp2D" do           
            num_of_nodes = :math.sqrt(num_of_nodes) |> Float.ceil |> :math.pow(2) |>trunc
        end

        Coordinator.start_link
        IO.puts "Coordinator is started..."        
        Coordinator.initialize_actor_system(:coordinator, num_of_nodes, topology, algorithm) 
        Process.send_after(:coordinator, {:mock_failure, failure_num}, 3000)        
        loop(num_of_nodes, topology, algorithm, failure_num, n - 1)
    end

    def loop(num_of_nodes, topology, algorithm, failure_num, n) do
        :timer.sleep 1000
        loop(num_of_nodes, topology, algorithm, failure_num, n)
    end
    
    #def round_up(num) do
    #    num = :math.sqrt(num) |> Float.ceil |> :math.pow(2) 
    #    num       
    #end
end