`timescale 1ns / 1ps

module apple(
    input clk,
    input btnrst,
    input[10:0] snakehead_x,
    input[10:0] snakehead_y,
    
    output[10:0] newapple_x,
    output[10:0] newapple_y
    );
    
    reg[10:0] x, randx = 11'd16;
    reg[10:0] y, randy = 11'd144;
    
    // when new apple needed
    // x generate number between 1-43
    // y generate number between 1-22
    // allows to fit game grid
    // values will be x32 to find real coordinates
    always @(posedge clk) begin
        if (btnrst) begin
            x = 11'd16;
            y = 11'd144;
        end
        x = x + 11'd32;
        if (x >= 11'd1424)begin
            x = 11'd16;
        end
        
        y = y + 11'd32;
        if (y >= 11'd880) begin
            y = 11'd144;
        end
    end
    
    assign newapple_x = x;
    assign newapple_y = y;
    
endmodule
