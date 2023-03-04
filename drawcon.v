`timescale 1ns / 1ps

module drawcon(
    input clk,
    input rst,
    input btnrst,
    input [252:0] snakepos_x,
    input [252:0] snakepos_y,
    input [5:0] length,
    input [10:0] applepos_x,
    input [10:0] applepos_y,

    input [10:0] curr_x,
    input [10:0] curr_y,
    
    input lose,
    input win,
    
    output [3:0] draw_r,
    output [3:0] draw_g,
    output [3:0] draw_b
    );
    
    reg [3:0] blk_r, blk_g, blk_b;
    reg [3:0] bg_r, bg_g, bg_b;
    
    //image signals
    parameter BLK_SIZE_X = 32, BLK_SIZE_Y = 32;
    parameter INFO_SIZE_X = 1408, INFO_SIZE_Y = 128;
    reg [17:0] infobar_addr = 0;
    wire [11:0] rom_pixel;
    reg [5:0] i;
    reg placed;
    reg game_end;
    
    //
    
    //background colour
    always@* begin
        game_end = win || lose;
        if(!lose) begin
            if(win) begin
                bg_r <= 4'b0000;
                bg_g <= 4'b1111;
                bg_b <= 4'b0000;
            end else begin
                if ((curr_x < 11'd16) || (curr_x > 11'd1424) || (curr_y < 11'd16) || (curr_y > 11'd880)) begin
                    bg_r <= 4'b1111;
                    bg_g <= 4'b1111;
                    bg_b <= 4'b1111;
                end else begin
                    bg_r <= 4'b0000;
                    bg_g <= 4'b0000;
                    bg_b <= 4'b0000;
                end
            end
        end else begin
            bg_r <= 4'b1111;
            bg_g <= 4'b0000;
            bg_b <= 4'b0000;
        end
    end
    
    //image block
    always@(posedge clk) begin
        if(!rst) begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
            infobar_addr = 0;
            placed = 0;
        end else begin
        
            //infobar            
            if(!game_end && (curr_x > 11'd15) && (curr_x < 11'd15+INFO_SIZE_X+1) && (curr_y > 11'd16) && (curr_y < 11'd16+INFO_SIZE_Y+1)) begin
                placed = 1;
                blk_r = rom_pixel[11:8];
                blk_g = rom_pixel[7:4];
                blk_b = rom_pixel[3:0];
                if(infobar_addr == ((INFO_SIZE_X * INFO_SIZE_Y)-1)) begin
                    infobar_addr = 0;
                end else begin
                    infobar_addr = infobar_addr + 1;
                end
            end
            
            //apple
            if (!game_end && (curr_x > applepos_x) && (curr_y > applepos_y) && (curr_x < applepos_x+BLK_SIZE_X-1) && (curr_y < applepos_y+BLK_SIZE_Y-1))begin 
                placed = 1;
                blk_r <= 4'b1111;
                blk_g <= 4'b1111;
                blk_b <= 4'b1111; 
            end
            
            //head
            if (!game_end && (curr_x > snakepos_x[10:0]) && (curr_x < snakepos_x[10:0]+BLK_SIZE_X-1) && (curr_y > snakepos_y[10:0]) && (curr_y < snakepos_y[10:0]+BLK_SIZE_Y-1)) begin
                placed = 1;
                blk_r <= 4'b1111;
                blk_g <= 4'b0000;
                blk_b <= 4'b0000; 
            end else begin 
                //body
                for(i=1; i < 22; i=i+1) begin
                    if (i < length) begin
                        if(!game_end && (curr_x > snakepos_x[11*i +: 11]) && (curr_x < snakepos_x[11*i +: 11]+BLK_SIZE_X-1) && (curr_y > snakepos_y[11*i +: 11]) && (curr_y < snakepos_y[11*i +: 11]+BLK_SIZE_Y-1)) begin
                            placed = 1;
                            blk_r <= 4'b0000;
                            blk_g <= 4'b1111;
                            blk_b <= 4'b0000; 
                        end
                    end
                end
            end 
            if(!placed && !game_end) begin
                blk_r <= 4'b0000;
                blk_g <= 4'b0000;
                blk_b <= 4'b0000;
            end
            placed <= 0;
         
        end
    end

    assign draw_r = (blk_r != 4'b0000) ? blk_r : bg_r;
    assign draw_g = (blk_g != 4'b0000) ? blk_g : bg_g;
    assign draw_b = (blk_b != 4'b0000) ? blk_b : bg_b;

    blk_mem_gen_0 info_inst(
        .clka(clk),
        .addra(infobar_addr),
        .douta(rom_pixel)
    );
    
endmodule