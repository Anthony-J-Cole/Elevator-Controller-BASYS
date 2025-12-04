module elevator (
    input        i_clk,
    input        i_rst,
    input        i_button_pressed,
    input  [2:0] i_button_value,
    
    output reg [2:0] o_floor
);
    reg [2:0] cur_floor;
    reg [1:0] cur_state, next_state;
    //Array of floors left to vist
    reg [7:0] to_visit;
    
    //Mask for swiching directions
    reg [7:0] mask;
    
    parameter   IDLE = 0,
                UP = 1,
                DOWN = 2;
    
    always @(posedge i_clk) begin 
        if(i_rst) begin // Reset Handling
            cur_state <= IDLE;
            to_visit <= 8'b00000000;
            cur_floor <= 0;
        end
        
        else begin
            to_visit[cur_floor] = 0;
            if(to_visit == 0) begin
                cur_state = IDLE;
                next_state = IDLE;
            end           
            
            //$strobe("current state: %d, to visit: %b, current floor: %d",next_state, to_visit, cur_floor);
            
            //Handle button and queueing
            if(i_button_pressed) begin
                if(to_visit == 8'b00000000)  begin //If to_visit is empty...
                    if(i_button_value >= cur_floor && cur_floor !== 7) begin //Decide inital direction
                        next_state <= UP;
                    end
                    else begin
                        next_state <= DOWN;
                    end
                end
                to_visit = to_visit | (8'b1 << i_button_value);    //Always add to array        
            end
            
            //Update the FSM
            cur_state = next_state;
            
            
            
            //Main FSM logic
            case(cur_state)
            IDLE : begin
                //$display("Elevator Idle");
                //if(to_visit != 0)
                    //$display("Elevator moving next clock??");
            end
            UP : begin
                //$display("Moving Up");
                mask = ~(8'b00000000 >> (cur_floor + 1));
                
                cur_floor = cur_floor + 1; //Move up
                
                if(to_visit == 0) //Complete transition to IDLE
                    next_state = IDLE; 
                else if(cur_floor >= 7 || ~(|(to_visit & mask))) //DONE --TODO--: Or is the highest floor in to_visit
                    //If all bits in to_visit higher than cur_floor are 0 then true;
                    //Inverted, OR reduced against AND'd mask. There is probably a easier way to do this...
                    next_state = DOWN;
                else 
                    next_state = UP;
            end
            DOWN : begin
                //$display("Moving Down");
                
                
                cur_floor = cur_floor - 1; //Move down
                
                //Create a mask with cur_floor number bits,
                //Bitwise and against to_visit, if = 0, then true
                if(to_visit == 0)
                    next_state = IDLE;
                else if(cur_floor <= 0 || (to_visit & ((1 << cur_floor) - 1)) == 0) //DONE --TODO--: or is the lowest floor in to_vist
                    next_state = UP;
                else
                    next_state = DOWN;
            end
            endcase
            
            o_floor = cur_floor;
        end
    end
endmodule

