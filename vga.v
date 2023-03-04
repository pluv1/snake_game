`timescale 1ns / 1ps

module vga(
    input clk,
    input rst,
    input [3:0] draw_r,
    input [3:0] draw_g,
    input [3:0] draw_b,
    output [10:0] curr_x,
    output [10:0] curr_y,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync, 
    output vsync
    );
    
    //internal signals
    reg [10:0] hcount;
    reg [9:0] vcount;
    reg [10:0] curr_x_r;
    reg [10:0] curr_y_r;
    
    
    wire display_region;
    wire line_end_h = (hcount == 11'd1903);
    wire line_end_v = (vcount == 10'd931);
    
    
    //hsync vsync assigning combinational
    assign hsync = ((hcount >= 11'd0) && (hcount <= 11'd151));
    assign vsync = ((vcount >= 10'd0) && (vcount <= 10'd2));
    
    assign display_region = ((hcount >= 11'd384) && (hcount <= 11'd1823) && (vcount >= 10'd31) && (vcount <= 10'd930));
    
    //pix assign combinational
    assign pix_r = (display_region) ? draw_r : 4'b0000;
    assign pix_g = (display_region) ? draw_g : 4'b0000;
    assign pix_b = (display_region) ? draw_b : 4'b0000;
    
    //hcount synchronous
    always@(posedge clk) begin
        if(!rst)
            hcount <= 11'd0;
        else begin
            if(line_end_h)
                hcount <= 11'd0;
            else 
                hcount <= hcount + 11'd1;
        end     
    end
    
    //vcount synchronous
    always@(posedge clk) begin
        if(!rst)
            vcount <= 10'd0;
        else begin
            if(line_end_v)
                vcount <= 10'd0;
            else 
                if(line_end_h)
                    vcount <= vcount + 10'd1;
        end     
    end
    
    //curr_x synchronous
    always@(posedge clk) begin
        if(!rst)
            curr_x_r <= 11'd0;
        else begin
            if((hcount >= 11'd384) && (hcount <= 11'd1824))begin
                curr_x_r <= curr_x_r + 11'd1;
            end else begin
                curr_x_r <= 11'd0;
            end
        end
    end
  
    
    //curr_y synchronous
    always@(posedge clk) begin
        if(!rst)
            curr_y_r <= 11'd0;
        else begin
            if(line_end_h) begin
                if((vcount >= 10'd31) && (vcount <= 10'd930))begin
                    curr_y_r <= curr_y_r + 11'd1;
                end else begin
                    curr_y_r <= 11'd0;
                end
             end
        end
    end
    
    assign curr_x = curr_x_r;
    assign curr_y = curr_y_r;
    
endmodule