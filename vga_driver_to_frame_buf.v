module vga_driver (
    input                   CLOCK_50,
    output         [6:0]    HEX0,
    output         [6:0]    HEX1,
    output         [6:0]    HEX2,
    output         [6:0]    HEX3,
    input          [3:0]    KEY,
    output         [9:0]    LEDR,
    input          [9:0]    SW,
    output                  VGA_BLANK_N,
    output         [7:0]    VGA_B,
    output                  VGA_CLK,
    output         [7:0]    VGA_G,
    output                  VGA_HS,
    output         [7:0]    VGA_R,
    output                  VGA_SYNC_N,
    output                  VGA_VS
);

// Turn off all displays
assign HEX0 = 7'h00;
assign HEX1 = 7'h00;
assign HEX2 = 7'h00;
assign HEX3 = 7'h00;

// Clock and reset
wire clk;
wire rst;
assign clk = CLOCK_50;
assign rst = KEY[0];

// Debounced switches
wire [9:0]SW_db;
debounce_switches db(
    .clk(clk),
    .rst(rst),
    .SW(SW), 
    .SW_db(SW_db)
);

// Parameters
parameter MEMORY_SIZE = 16'd19200;
parameter PIXEL_VIRTUAL_SIZE = 16'd4;
parameter VGA_WIDTH = 16'd640;
parameter VGA_HEIGHT = 16'd480;
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE;
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE;

// Game state registers
reg [14:0] shape_position0, shape_position1, shape_position2, shape_position3;
reg [14:0] shape_position4, shape_position5, shape_position6, shape_position7;
reg [14:0] shape_position8, shape_position9, shape_position10, shape_position11;
reg [14:0] shape_position12, shape_position13, shape_position14, shape_position15;


reg [23:0] shape_color;
reg [23:0] background_color;
reg [23:0] platform_color;
reg move_flag;

// VGA interface signals
reg [14:0] the_vga_draw_frame_write_mem_address;
reg [23:0] the_vga_draw_frame_write_mem_data;
reg the_vga_draw_frame_write_a_pixel;

// VGA signals
wire active_pixels;
wire frame_done;
wire [9:0]x;
wire [9:0]y;

// VGA driver instance
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
    .the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
    .the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
    .the_vga_draw_frame_write_a_pixel(the_vga_draw_frame_write_a_pixel)
);

// Debug output
assign LEDR = shape_position1[9:0];

reg [4:0] S,NS;
reg [4:0] i,j,k; 

parameter START = 4'd0;
parameter WAIT = 4'd1;
parameter RIGHT = 4'd2;
parameter LEFT = 4'd3;
parameter UP = 4'd4;
parameter DOWN = 4'd5;
parameter CLEAR = 4'd6;
parameter UPDATE = 4'd7;
parameter WRITE = 4'd9;
parameter INCREMENT_I = 4'd10;
parameter INCREMENT_J = 4'd11;
parameter INCREMENT_K = 4'd12;

always @(posedge clk or negedge rst) 
begin

if (rst == 0)
	S <= START;
else 
	S <= NS; 

end


always @(*) 
begin
case(S)
START: NS = WAIT;
WAIT: 
if(!KEY[1])
	NS = RIGHT;
else if (!KEY[2])
	NS = LEFT;
else if (!KEY[3])
	NS = UP;
RIGHT: NS = CLEAR;
LEFT: NS = CLEAR; 
UP: NS = CLEAR; //PLACEHODLER!
//implement later. If the floor is not black ns is falling, else ns is wait
DOWN: NS = CLEAR; //PLACEHOLDER
CLEAR:
	if (i < 16) 
		NS = INCREMENT_I;
	else
		NS = UPDATE;
UPDATE: 
	if (j < 16) 
		NS = INCREMENT_J;
	else 
		NS = WRITE;
WRITE:
	if (k < 16) 
		NS = INCREMENT_K;
	else 
		NS = WAIT;
	
INCREMENT_I:
	NS = CLEAR;
INCREMENT_J:
	NS = UPDATE;
INCREMENT_K:
	NS = WRITE; 
	
default: NS = START;  

endcase
end 

always @(posedge clk or negedge rst) 
begin

case(S)

START:
begin
    shape_position[0]  <= 15'd235;
    shape_position[1]  <= 15'd236;
    shape_position[2]  <= 15'd237;
    shape_position[3]  <= 15'd238;
    shape_position[4]  <= 15'd355;
    shape_position[5]  <= 15'd356;
    shape_position[6]  <= 15'd357;
    shape_position[7]  <= 15'd358;
    shape_position[8]  <= 15'd475;
    shape_position[9]  <= 15'd476;
    shape_position[10] <= 15'd477;
    shape_position[11] <= 15'd478;
    shape_position[12] <= 15'd595;
    shape_position[13] <= 15'd596;
    shape_position[14] <= 15'd597;
    shape_position[15] <= 15'd598;
	 
	 shape_color <= 24'hFFFFFF;
	 background_color <= 24'h000000;
	 platform_color <= 24'h00FF00;
	 i <= 0;
	 j <= 0;
	 k <= 0;
end

CLEAR:
begin
	the_vga_draw_frame_write_mem_address <= shape_position[i];
	the_vga_draw_frame_write_mem_data <= background_color;
	the_vga_draw_frame_write_a_pixel <= 1'b1;	
end
UPDATE:
	shape_position[j] <= shape_position[j] + 4;
WRITE:
begin
	the_vga_draw_frame_write_mem_address <= shape_position[k];
   the_vga_draw_frame_write_mem_data <= shape_color;
   the_vga_draw_frame_write_a_pixel <= 1'b1;
end
INCREMENT_I:
begin
	i <= i + 1;
	the_vga_draw_frame_write_a_pixel <= 1'b0;
end
INCREMENT_J:
begin
	j <= j +1;
	the_vga_draw_frame_write_a_pixel <= 1'b0;
end
INCREMENT_K:
begin
	k <= k + 1;
	the_vga_draw_frame_write_a_pixel <= 1'b0;
end
WAIT: 
begin
	i <= 0;
	j <= 0;
	k <= 0;
	the_vga_draw_frame_write_a_pixel <= 1'b0;
end
endcase

end

endmodule