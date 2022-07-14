//TB_mst

`timescale 1ns/1ps 

`define D_AXI4_DATA_SIZE     64
`define D_AXI4_ADDRESS_WIDTH 45
`define D_AXI4_ID_WIDTH      7
`define D_AXI4_BURST_LENGHT  10

`define mst_bfm0 UP.MASTER_U0

module TB_mst;
	integer                          iterations=1;
	integer                          i,j, l;
    //AXI4 Master
	reg [7:0]                        alen0       = `D_AXI4_BURST_LENGHT-1;
    reg [`D_AXI4_DATA_SIZE-1:0]      wdata0 [`D_AXI4_BURST_LENGHT-1:0];
    reg [`D_AXI4_DATA_SIZE-1:0]      rdata0 [`D_AXI4_BURST_LENGHT-1:0];
	reg [(`D_AXI4_DATA_SIZE/8)-1:0]  wstrb0 [`D_AXI4_BURST_LENGHT-1:0];
    reg[`D_AXI4_ID_WIDTH-1:0]        id0         = 'b0;
    reg[2:0]                         asize0      = $clog2(`D_AXI4_DATA_SIZE>>2)-1;
    reg[3:0]                         rresp0      = 'b0;
    reg                              rlast0      = 'b0; 
    reg[1:0]                         bresp0      = 'b0;
    reg                              user0     	 = 'b0;
    reg[3:0]                         arqos0   	 = 'b0;
	reg                              mst0_status = 'b0;
reg res;

    function reg check_data_axi4;
    input dummy;
	integer k;
	reg res;
	begin
		res=0;
	  	for (k=0; k<`D_AXI4_BURST_LENGHT; k=k+1)
	  	begin
		   if (wdata0[k] !== rdata0[k])
		   begin
			    $display("AXI4 wdata[%d]=%x rdata[%d]=%x", k, wdata0[k], k, rdata0[k]);
			    res = 1'b1;
		   end
	  	end
		check_data_axi4 = res;
	end
	endfunction

initial
    begin
		
        for (i=0; i<(`D_AXI4_BURST_LENGHT); i=i+1)
		begin
		    wdata0[i] = `D_AXI4_DATA_SIZE'({$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, 
											$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom,
											$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, 
											$urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom, $urandom});
			rdata0[i] = 0;
			wstrb0[i] = (`D_AXI4_DATA_SIZE/8)'('hffffffffffffffffffffffffffffffff);
		end


	    @(UP.MASTER_U0.ARESETn===0);
	    @(UP.MASTER_U0.ARESETn===1);
		#1;
for (i=0; i<iterations; i=i+1)
        begin
			`mst_bfm0.BfmWriteAddress(id0, 'h0, 'h0, alen0, asize0, 'd1, 'd0, 'd0, 'd0, 'd0, 'd0);
			
			for (j=0; j<(alen0+1); j=j+1)
			begin
				`mst_bfm0.BfmWriteData( wdata0[j], wstrb0[j], j==alen0, user0);
			end
            `mst_bfm0.BfmWaitForWriteResponse(id0, bresp0, user0);
            `mst_bfm0.BfmReadAddress(id0, 'h0, 'h0, alen0, asize0, 'd1, 'd0, 'd0, 'd0, 'd0, 'd0);
			
	        for (l=0; l<(`D_AXI4_BURST_LENGHT); l=l+1)
			begin
	            `mst_bfm0.BfmWaitForReadResponse(id0, rresp0, rdata0[l], rlast0, user0);
			end
			res=check_data_axi4(0);
            if (res)
            begin
                $display("ERROR on data checking - bfm0; iteration=%d", i);
                mst0_status = 1;
            end
        end
        if (!mst0_status)
            $display("\n\nBFM0 test passed");
        else
            $display("\n\nBFM0 test failed");
    end
endmodule
