module gameDesign	(
	input 		          		CLOCK_50,
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	input 		     [3:0]		KEY,
	output		     [9:0]		LEDR,
	input 		     [9:0]		SW,
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

// Turn off all displays.
assign	HEX0		=	7'h00;
assign	HEX1		=	7'h00;
assign	HEX2		=	7'h00;
assign	HEX3		=	7'h00;

// DONE STANDARD PORT DECLARATION ABOVE
/* HANDLE SIGNALS FOR CIRCUIT */
wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = SW[0];

wire [9:0]SW_db;

debounce_switches db(
.clk(clk),
.rst(rst),
.SW(SW), 
.SW_db(SW_db)
);

// VGA DRIVER
wire active_pixels; // is on when we're in the active draw space
wire frame_done;
wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

/* the 3 signals to set to write to the picture */
reg [14:0] the_vga_draw_frame_write_mem_address;
reg [23:0] the_vga_draw_frame_write_mem_data;
reg the_vga_draw_frame_write_a_pixel;

/* This is the frame driver point that you can write to the draw_frame */
vga_frame_driver my_frame_driver(
	.clk(clk),
	.rst(rst),

	.active_pixels(active_pixels),
	.frame_done(frame_done),

	.x(x),
	.y(y),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),
	.VGA_B(VGA_B),
	.VGA_G(VGA_G),
	.VGA_R(VGA_R),

	/* writes to the frame buf - you need to figure out how x and y or other details provide a translation */
	.the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
	.the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
	.the_vga_draw_frame_write_a_pixel(the_vga_draw_frame_write_a_pixel)
);

reg [15:0]i;
reg [7:0]S;
reg [7:0]NS;

parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640; 
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

/* idx_location stores all the locations in the */
reg [14:0] idx_location;
reg [14:0] shape_location;

reg start_frame_delay;
wire frame_delay_done;

wire [23:0] shape_color = 24'hFFFFFF;
wire [23:0] background_color = 24'h000000;  
/* !!!!!!!!!NOTE!!!!!!!
 - FLAG logic is a bad way to approach this, but I was lazy - I should implement this as an FSM for the button grabs.  */
reg flag1;
reg flag2;

// Just so I can see the address being calculated
assign LEDR = S;

parameter START = 8'd0, INIT = 8'd1, WAIT = 8'd2, RIGHT = 8'd3, LEFT = 8'd4, UP = 8'd5, DOWN = 8'd6, DELAY_ON = 8'd7, DELAY_OFF = 8'd8, CLEAR = 8'd9, UPDATE = 8'd10, WRITE = 8'd11;

always @ (posedge clk or negedge rst)
begin
	if (!rst)
		S <= START;
	else 
		S <= NS;
end

always @ (*)
begin
case (S)
        START: begin
            NS = INIT;
        end

        INIT: begin
            NS = WAIT;
        end

        WAIT: begin
            if(!KEY[0])
					NS = RIGHT;
				else if(!KEY[1])
					NS = LEFT;
				else if(!KEY[2])
					NS = UP;
				//else if(KEY[3])
					//NS = DOWN;
        end

        RIGHT: begin
            NS = CLEAR;
        end

        LEFT: begin
            NS = CLEAR;
        end

        UP: begin
            NS = CLEAR;
        end

        DOWN: begin
            NS = CLEAR;
        end

        DELAY_ON: begin
            if(frame_delay_done)
					NS = DELAY_OFF;
				else 
					NS = DELAY_ON; 
        end

        DELAY_OFF: begin
            NS = WAIT;
        end

        CLEAR: begin
            NS = UPDATE;
        end

        UPDATE: begin
            NS = WRITE; 
        end

        WRITE: begin
            NS = DELAY_ON; 
        end

        default: begin
            // Add logic for default state
        end
    endcase
end

always @ (posedge clk or negedge rst) 
begin
if (!rst)
	begin
	idx_location <= 15'd0;
	shape_location <= 15'd0;
	start_frame_delay <= 1'd0; 
	
	the_vga_draw_frame_write_mem_address <= 15'd0;
	the_vga_draw_frame_write_mem_data <= 24'd0;
	the_vga_draw_frame_write_a_pixel <= 1'd0;
	end
else begin
    case (S)
        START: begin
            idx_location <= 15'd0;
				shape_location <= 15'd0;
				start_frame_delay <= 1'd0; 
				
				the_vga_draw_frame_write_mem_address <= 15'd0;
				the_vga_draw_frame_write_mem_data <= 24'd0;
				the_vga_draw_frame_write_a_pixel <= 1'd0;
        end

        INIT: begin
            the_vga_draw_frame_write_mem_address <= 15'd0;
				the_vga_draw_frame_write_mem_data <= shape_color;
				the_vga_draw_frame_write_a_pixel <= 1'b1;
        end

        WAIT: begin
            the_vga_draw_frame_write_a_pixel <= 0;
        end

        RIGHT: begin
					shape_location <= shape_location + 1'b1; 
        end

        LEFT: begin
            // Add logic for LEFT state
        end

        UP: begin
            // Add logic for UP state
        end

        DOWN: begin
            
        end

        DELAY_ON: begin
            start_frame_delay = 1'b1; 
        end

        DELAY_OFF: begin
            //start_frame_delay = 1'b0; 
        end

        CLEAR: begin
				the_vga_draw_frame_write_mem_address <= idx_location;
				the_vga_draw_frame_write_mem_data <= background_color;
				the_vga_draw_frame_write_a_pixel <= 1'b1;
        end

        UPDATE: begin
            the_vga_draw_frame_write_a_pixel <= 1'b0; 
        end

        WRITE: begin
				idx_location <= shape_location; 
            the_vga_draw_frame_write_mem_address <= shape_location;
				the_vga_draw_frame_write_mem_data <= shape_color;
				the_vga_draw_frame_write_a_pixel <= 1'b1;
        end

        default: begin
            // Add logic for default state
        end
 
    endcase
end
end

delay mydelay (
    clk,
    rst, 
    start_frame_delay,
    frame_delay_done
);

endmodule


 


