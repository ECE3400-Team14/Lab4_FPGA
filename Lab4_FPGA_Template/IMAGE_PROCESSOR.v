`define SCREEN_WIDTH 176
`define SCREEN_HEIGHT 144
`define NUM_BARS 3
`define BAR_HEIGHT 48

module IMAGE_PROCESSOR (
	PIXEL_IN,
	CLK,
	VGA_PIXEL_X,
	VGA_PIXEL_Y,
	VGA_VSYNC_NEG,
	RESULT,
	shape,
	color_count,
	top,
	first,
	second,
	third,
	bottom,
	colorFinished,
	shapeFinished
);


//=======================================================
//  PORT declarations
//=======================================================
input	[7:0]	PIXEL_IN;
input 		CLK;

input [9:0] VGA_PIXEL_X;
input [9:0] VGA_PIXEL_Y;
input			VGA_VSYNC_NEG;

output reg [7:0] RESULT = 8'b0;

reg [14:0] blue;
reg [14:0] red;
output reg colorFinished;

always @ (posedge CLK) begin
	if (!colorFinished) begin
		if (VGA_PIXEL_X == 0 && VGA_PIXEL_Y == 0) begin
			blue <= 0;
			red <= 0;
		end
		else begin
			if (VGA_PIXEL_X < 176 && VGA_PIXEL_Y < 144) begin
				if (PIXEL_IN[7:5] >= 1 && PIXEL_IN[1:0] == 0 && PIXEL_IN[4] == 0) begin
					red <= red + 1;
				end
				else begin
					red <= red;
				end
				if (PIXEL_IN[7:6] == 0 && PIXEL_IN[1:0] >= 1 && PIXEL_IN[4] == 0) begin
					blue <= blue + 1;
				end
				else begin
					blue <= blue;
				end
			end
		end
	end
end

output reg shapeFinished;
output reg [1:0] shape;
output reg [7:0] top;
output reg [7:0] first;
output reg [7:0] second;
output reg [7:0] third;
output reg [7:0] bottom;
output reg [7:0] color_count;
always @ (posedge CLK) begin
	if (!shapeFinished && colorFinished) begin
		if (VGA_PIXEL_X == 0) begin
			color_count = 0;
		end else begin
			if (VGA_PIXEL_X < 176 && VGA_PIXEL_Y < 144 && (PIXEL_IN[7:6] >= 1 && PIXEL_IN[1:0] == 0 && PIXEL_IN[4] == 0 && RESULT[0] == 1) || (PIXEL_IN[7:6] == 0 && PIXEL_IN[1:0] >= 1 && PIXEL_IN[4] == 0 && RESULT[1] == 1)) begin
				color_count = color_count + 1;
			end
		end
		if (top == 0 && color_count > 20) begin
			top = VGA_PIXEL_Y;
		end
		if (top != 0 && bottom == 0 && color_count < 21 && VGA_PIXEL_X == 175) begin
			bottom = VGA_PIXEL_Y;
		end
		if (VGA_PIXEL_Y == 48 && VGA_PIXEL_X == 175) begin
			first = color_count;
		end
		if (VGA_PIXEL_Y == 72 && VGA_PIXEL_X == 175) begin
			second = color_count;
		end
		if (VGA_PIXEL_Y == 96 && VGA_PIXEL_X == 175) begin
			third = color_count;			
		end
		if (first != 0 && second != 0 && third != 0) begin
			if (((first-second)**2 < (second**2/100)) && ((second-third)**2 < (third**2/100))) begin
			   //square
				shape = 2'b11;
			end else begin
				if (second-first > second/5 && third-second > third/5) begin
					//triangle
					shape = 2'b10;
				end
				else begin
					if (second-first > second/5 && second-third > second/5) begin
						//diamond
						shape = 2'b01;
					end
				end
			end
		end
	end
	else begin
		if (!colorFinished)
		begin
			shape = 0;
			top = 0;
			first = 0;
			second = 0;
			third = 0;
			bottom = 0;
		end
	end
end

always @ (*) begin
	//ISSUE: RESULT is not clearing
	if (!VGA_VSYNC_NEG) begin
		colorFinished <= 0;
		shapeFinished <= 0;
		RESULT <= 8'b0;
	end else begin
		if (red > 1600) begin//12678
			RESULT <= 8'b00000001;
			colorFinished <= 1;
		end
		else begin
			if (blue > 1600) begin
				RESULT <= 8'b00000010;
				colorFinished <= 1;
			end
			else begin
				RESULT <= 8'b0;
				colorFinished <= 0;
			end
		end
		if (shape != 0) begin
			shapeFinished <= 1;
		end else begin
			shapeFinished <= shapeFinished;
		end
	end
end

endmodule