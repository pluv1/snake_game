`timescale 1ns / 1ps

module game_top(
    input clk,
    input rst,
    input [4:0] btn,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync, 
    output vsync, 
    output a,b,c,d,e,f,g,
    output [7:0] an
    );
    
    //draw wires
    wire [3:0] draw_r;
    wire [3:0] draw_g;
    wire [3:0] draw_b;
    wire [10:0] curr_x;
    wire [10:0] curr_y;
    
    //apple wires & registers
    reg new;
    wire [10:0] newapple_x;
    wire [10:0] newapple_y;
    reg [10:0] applepos_x = 11'd656;
    reg [10:0] applepos_y = 11'd498;

    //game wires & registers
    reg [26:0] clk_div;
    reg game_clk;
    wire lose;
    wire[5:0] points;
    wire win;
    wire pixclk;
    
    //snake registers
    reg [252:0] snakepos_x, snakepos_y;
    reg [53:0] direction; //0 = right, 1 = down, 2 = left, 3 = up
    reg [5:0] length = 9;
    reg [5:0] i;
    
    //seven seg registers
    reg [3:0] num_1, num_2;
    
    //clock generator
    clk_wiz_0 inst
    (
    // Clock out ports  
    .clk_out1(pixclk),
    // Clock in ports
    .clk_in1(clk)
    );
    
    //setting up key variables
    initial begin
        for (i=0; i < 22 ; i=i+1) begin
            snakepos_x[i*11 +: 11] = 11'd784 - (i * 11'd32);
            snakepos_y[i*11 +: 11] = 11'd464;
        end 
        direction = 54'd0;
        length = 5'd1;
        num_1 = 4'h1;
        num_2 = 4'h0;
    end
    
    //game clock generation
    always@(posedge clk) begin
        if(!rst) begin
            clk_div <= 0;
            game_clk <= 0;
        end else begin
            if (clk_div == 27'd10600000) begin
                clk_div <= 0;
                game_clk <= !game_clk;
            end else begin
                clk_div <= clk_div + 1;
            end
        end
    end

    //direction choice and block movement
    /* Caterpillar can move up, down, left, right using buttons. 
    Cannot move backwards into itself
    Doesn't use turn mechanics as no modulo function */
    
    always@(posedge game_clk) begin
        if (btn[0]) begin
            direction = 54'd0;
            length = 5'd1;
            new = 1;
            num_1 = 4'h1;
            num_2 = 4'h0;
            for (i=0; i < 22 ; i=i+1) begin
                snakepos_x[i*11 +: 11] = 11'd784 - (i * 11'd32);
                snakepos_y[i*11 +: 11] = 11'd464;
            end 
        end else begin
            if (points > length) begin
                if(num_1 + 1 == 10) begin
                    num_1 = 4'h0;
                    num_2 = num_2 + 4'h1;
                end else begin 
                    num_1 = num_1 + 4'h1;
                end
                length = points;
                applepos_x = newapple_x;
                applepos_y = newapple_y;
            end
            
            //direction assignment 
            for (i=22; i > 0; i=i-1) begin
                direction[2*i +: 2] = direction[2*(i-1) +: 2];
            end
            case(btn[4:1])
                4'b0010: begin //turn left
                    if(direction[1:0] != 2'd0) begin
                        direction[1:0] = 2'd2;
                    end else begin
                        direction[1:0] = direction[1:0];
                    end
                end
                4'b0100: begin // turn right
                    if(direction[1:0] != 2'd2) begin
                        direction[1:0] = 2'd0;
                    end else begin
                        direction[1:0] = direction[1:0];
                    end
                end
                4'b1000: begin // turn up
                    if(direction[1:0] != 2'd1) begin
                        direction[1:0] = 2'd3;
                    end else begin
                        direction[1:0] = direction[1:0];
                    end
                end
                4'b0001: begin // turn down
                    if(direction[1:0] != 2'd3) begin
                        direction[1:0] = 2'd1;
                    end else begin
                        direction[1:0] = direction[1:0];
                    end
                end
                default: begin
                    direction[1:0] = direction[1:0];
                end
            endcase
            
            //looped movement controller
            for (i=0; i < 22; i = i+1) begin
                if(direction[2*i +: 2] == 2'd0)begin 
                    if (snakepos_x[11*i +: 11] < (11'd1424-11'd64+11'd1)) begin  //right
                        snakepos_x[11*i +: 11] = snakepos_x[11*i +: 11] + 11'd32;
                    end else begin
                        snakepos_x[11*i +: 11] = 11'd16;
                    end   
                end
                if(direction[2*i +: 2] == 2'd1)begin
                    if (snakepos_y[11*i +: 11] > (11'd144+11'd32-11'd1)) begin    //down
                        snakepos_y[11*i +: 11] = snakepos_y[11*i +: 11] - 11'd32;
                    end else begin
                        snakepos_y[11*i +: 11] = 11'd880 - 11'd32;
                    end
                end
                if (direction[2*i +: 2] == 2'd2) begin 
                    if (snakepos_x[11*i +: 11] > (11'd16+11'd32-11'd1)) begin  //left
                        snakepos_x[11*i +: 11] = snakepos_x[11*i +: 11] - 11'd32;
                    end else begin
                        snakepos_x[11*i +: 11] = 11'd1424 - 11'd32;
                    end
                end
                if(direction[2*i +: 2] == 2'd3) begin 
                    if (snakepos_y[11*i +: 11] < (11'd880-11'd64+11'd1)) begin  //up
                        snakepos_y[11*i +: 11] = snakepos_y[11*i +: 11] + 11'd32;
                    end else begin
                        snakepos_y[11*i +: 11] = 11'd144;
                    end
                end
            end
        end
    end 
    
    seginterface seg_inst(
        .clk(clk),
        .rst(rst), 
        .num_1(4'h2),
        .num_2(4'h2),
        .num_3(num_1),
        .num_4(num_2),
        .an(an), 
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g)
    );
    
    apple apple_inst(
    .clk(clk),
    .btnrst(btn[0]),
    .snakehead_x(snakepos_x[10:0]),
    .snakehead_y(snakepos_y[10:0]),
    .newapple_x(newapple_x),
    .newapple_y(newapple_y)
    );
    
    collisioncon collision_inst(
        .clk(game_clk),                               
        .reset(btn[0]),    
        .applepos_x(applepos_x),
        .applepos_y(applepos_y),                                  
        .snakepos_x(snakepos_x),                 
        .snakepos_y(snakepos_y),                 
        .length(length),                                                  
        .curr_x(curr_x),                      
        .curr_y(curr_y),
        .points(points),                                               
        .lose(lose),
        .win(win) 
    );
    
    drawcon drawcon_inst (
        .clk(pixclk),
        .rst(rst),
        .snakepos_x(snakepos_x),
        .snakepos_y(snakepos_y),
        .length(length),
        .applepos_x(applepos_x),
        .applepos_y(applepos_y),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .lose(lose),
        .win(win),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b)
    );
    
    vga vga_inst (
        .clk(pixclk),
        .rst(rst),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b),
        .pix_r(pix_r),
        .pix_g(pix_g),
        .pix_b(pix_b),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .hsync(hsync), 
        .vsync(vsync)
    ); 
endmodule 