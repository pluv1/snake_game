`timescale 1ns / 1ps

module collisioncon(
    input clk,       
    input reset,
    
    input[10:0] applepos_x,
    input[10:0] applepos_y,
    
    input[252:0] snakepos_x,
    input[252:0] snakepos_y,
    input[5:0] length,
    
    input[10:0] curr_x,
    input[10:0] curr_y,
    
    output[5:0] points, //snake head hits apple
    output lose,   //snake head hits body 
    output win
);

    reg [5:0] i = 0;
    reg lost = 0;
    reg [5:0] hit = 2;
    reg win_r = 0;
    
     //points
     always@(posedge clk) begin    
        if (reset) begin 
           hit = 2;
           win_r = 0;
        end else begin                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
             if ((snakepos_x[10:0] == applepos_x) && (snakepos_y[10:0] == applepos_y))begin       
                 hit = hit + 1; 
                 if (hit == 22) begin
                    win_r = 1;
                 end                                                                                         
             end  
         end                                                                                                                                                                                                                                                                                              
     end        
                                                                                                                   
    //lose
    always@(posedge clk) begin
        if (reset) begin 
            lost = 0;
        end else begin
            for (i=1; i < 23; i=i+1) begin
                if (i < length) begin
                    if ((snakepos_x[10:0] == snakepos_x[11*i +: 11]) && (snakepos_y[10:0] == snakepos_y[11*i +: 11])) begin
                        lost = 1;
                    end
                end
            end
        end
    end
    
    assign lose = lost;
    assign points = hit;
    assign win = win_r;
endmodule