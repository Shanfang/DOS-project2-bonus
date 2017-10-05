defmodule Actor do
    import Topology

    use GenServer

    ######################### client API ####################

    def start_link(index) do
        actor_name = index |> Integer.to_string |> String.to_atom
        GenServer.start_link(__MODULE__, index, [name: actor_name])
    end

    def setup_neighbors(actor_name, num_of_nodes, topology) do
        GenServer.cast(actor_name, {:setup_neighbors, num_of_nodes, topology})
    end

    def start_gossip(actor_name) do
       GenServer.cast(actor_name, :start_gossip)     
    end

    def start_push_sum(actor_name, delta_s, delta_w) do
        GenServer.cast(actor_name, {:start_push_sum, delta_s, delta_w})             
    end

    def mock_failure(actor_name) do
        GenServer.cast(actor_name, :mock_failure)             
    end   
    ######################### callbacks ####################

    def init(index) do 
        state = %{id: 0, neighbors: [], alive: true, counter: 0, s_value: 0, w_value: 1, unchange_times: 0}
        new_state = %{state | id: index}
        {:ok, new_state}
    end

    def handle_cast({:setup_neighbors, num_of_nodes, topology}, state) do
        neighbors = find_neighbors(state[:id], num_of_nodes, topology) 
        new_state = %{state | neighbors: neighbors} 
        {:noreply, new_state}        
    end
    # send rumor to its neighbors, choose neighbor according to topology matching
    def handle_cast(:start_gossip, state) do
        case state[:alive] do
            true ->
                new_counter = state[:counter] + 1
                if new_counter == 10 do
                    Coordinator.converged(:coordinator, {:converged, state[:id]})
                    #Process.exit(self(), :kill)
                    new_state = %{state | alive: false}
                end 
                propagate_gossip(state[:neighbors])
                # gossip_resend
                Process.send_after(self(), :gossip_resend, 500) # resend after 1 second                
        end 
        new_state = %{state | counter: new_counter}
        {:noreply, new_state}
    end

    # when receiving push_sum msg
    def handle_cast({:start_push_sum, delta_s, delta_w}, state) do
        case state[:alive] do 
            true ->
                previous_ration = state[:s_value] / state[:w_value]
                new_s = state[:s_value] + delta_s
                new_w = state[:w_value] + delta_w
                current_ration = new_s / new_w
                new_counter = state[:counter] + 1
                unchange_times = check_unchange(current_ration, previous_ration, state[:unchange_times])
                if unchange_times == 3 do
                    Coordinator.converged(:coordinator, {:converged, state[:id]})                    
                    #Process.exit(self(), :kill)
                    new_state = %{state | alive: false}                    
                end 

                propagate_push_sum(state[:neighbors], new_s / 2, new_w / 2) 
                Process.send_after(self(), :push_sum_resend, 500) # resend after 1 second                
                s_value = new_s / 2
                w_value = new_w / 2
        end
        new_state = %{state | counter: new_counter, s_value: s_value, w_value: w_value, unchange_times: unchange_times}
        {:noreply, new_state}
    end

    def handle_info(:gossip_resend, state) do
        # IO.puts "resending gossip rumor"
        Actor.start_gossip(self())
        {:noreply, state}
    end

    def handle_info(:push_sum_resend, state) do
        # IO.puts "resending push_sum rumor"        
        Actor.start_push_sum(self(), state[:s_value] / 2, state[:w_value] / 2)
        new_state = %{state | s_value: state[:s_value] / 2, w_value: state[:w_value] / 2} 
        {:noreply, new_state}
    end
    
    def handle_cast(:mock_failure, state) do
        new_state = %{state | alive: false}
        {:noreply, new_state}
    end

    ######################### helper functions ####################
    # find neighbors and return a list
    defp find_neighbors(index, num_of_nodes, topology) do
        neighbors = 
            case topology do
                "full" ->               
                    Topology.neighbor_full(index, num_of_nodes)
                "2D" ->
                    Topology.neighbor_2D(index, num_of_nodes)
                "line" ->
                    Topology.neighbor_line(index, num_of_nodes)
                "imp2D" ->
                    Topology.neighbor_imp2D(index, num_of_nodes)
                _ ->
                    []
                    IO.puts "Invalid topology, please try again!"
            end
        neighbors       
    end

    defp propagate_gossip(neighbors) do
        Enum.each(neighbors, fn(neighbor) -> 
            Actor.start_gossip(neighbor |> Integer.to_string |> String.to_atom)                            
        end)           
    end

    defp propagate_push_sum(neighbors, delta_s, delta_w) do
        Enum.each(neighbors, fn(neighbor) -> 
            Actor.start_push_sum(neighbor |> Integer.to_string |> String.to_atom, delta_s, delta_w)                            
        end)                
    end

    defp check_unchange(current_ration, previous_ration, unchange_times) do
        unchange = 
            case abs(current_ration - previous_ration) < :math.pow(10, -10) do
                true ->
                    unchange_times + 1
                _ ->
                    0
            end
        unchange
    end

    # resend rumor to neighbors
    #defp gossip_resend do
    #    Process.send_after(self(), {:gossip_resend, num_of_nodes, topology}, 1000) # resend after 1 second
    #end

    #defp push_sum_resend do
    #    Process.send_after(self(), {:push_sum_resend, num_of_nodes, topology}, 1000) # resend after 1 second
    #end
end