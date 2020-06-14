//author Kayas Ahmed

module fifo
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=12 )
(
	input [(DATA_WIDTH-1):0] data_in,
	input we, re, clk,rst,
	output reg [(DATA_WIDTH-1):0] data_out,
	output  empty, full
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
  reg [ADDR_WIDTH-1:0] addr_b,addr_a;
  integer avail_data;
  
  integer i;
initial begin
    for (i=0;i<2**ADDR_WIDTH-1;i=i+1) begin
        ram[i]=0;
    end
    data_out=0;
end
	// Port A 
	always @ (posedge clk)
	begin
		if (we) 
		begin
			ram[addr_a] <= data_in;	
		end
	end 

	// Port B 
	always  @ (re,clk)
	begin
	 data_out = ram[addr_b];
	end
	
	// addr logic for fifo
	always @ (posedge clk)
	begin
	  if (rst)
	    begin
	       avail_data=0;
	       addr_a=0;
	       addr_b=0;
	    end
	   else
	     begin
	     if(we)
	     begin
	      
	           addr_a = addr_a + 1;
	           avail_data=avail_data+1;
	      end
	       if(re && (empty!=1))
	       begin
	        addr_b= addr_b + 1;
	           avail_data=avail_data-1;
	            end
	       
	   	      
	end
	end 
	assign empty= (avail_data==0? 1: 0); 
  assign full= (avail_data==2**ADDR_WIDTH-1? 1: 0); 	

endmodule
