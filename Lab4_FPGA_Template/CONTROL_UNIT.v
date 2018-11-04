module CONTROL_UNIT (
  CLK,
  HREF,
  VSYNC,
  input_data,
  output_data,
  X_ADDR,
  Y_ADDR,
  w_en
);

input CLK;
input [7:0] input_data;
input HREF;
input VSYNC;

output reg [14:0] X_ADDR;
output reg [14:0] Y_ADDR;
output reg w_en;
output [7:0] output_data;

reg write = 0;
reg [7:0] part1;
reg [7:0] part2;

always @ (posedge CLK) begin
  if (HREF)
  begin
    if (write == 0)
    begin
      part1 <= input_data;
	   write <= 1;
	   w_en <= 1;
		X_ADDR <= X_ADDR;
    end
    else
	 begin
      part2 <= input_data;
	   write <= 0;
	   w_en <= 1;
		X_ADDR <= X_ADDR + 1;
    end
  end
  else
  begin
    w_en <= 0;
	 write <= 0;
	 X_ADDR <= 0;
  end
end

always @ (posedge VSYNC, negedge HREF) begin
	if (VSYNC) begin
		Y_ADDR <= 0;
	end
	else
	begin
		Y_ADDR <= Y_ADDR + 1;
	end
end


DOWNSAMPLE downsampler(
  .RGB565({part1, part2}),
  .RGB332(output_data)
);

  
endmodule
