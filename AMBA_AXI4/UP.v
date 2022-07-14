//TB_slv;
`timescale 1ns/1ps 

`define D_AXI4_DATA_SIZE     64
`define D_AXI4_ADDRESS_WIDTH 45
`define D_AXI4_ID_WIDTH      7
`define D_AXI4_BURST_LENGHT  10

`define slv_bfm0 UP.SLAVE_U0
module TB_slv;
		integer i0,j0,l0;
		integer i1,j1,l1;
    reg [`D_AXI4_DATA_SIZE-1:0]      data0 [256:0];
	reg [(`D_AXI4_DATA_SIZE/8)-1:0]  wstrb0[256:0];
    reg [`D_AXI4_ID_WIDTH-1:0]       awid0    ='b0; 
    reg [`D_AXI4_ADDRESS_WIDTH-1:0]  awaddr0  ='b0; 
    reg [7:0]                        awlen0   ='b0; 
    reg [3:0]                        awregion0='b0; 
    reg [2:0]                        awsize0  ='b0; 
    reg [1:0]                        awburst0 ='b0; 
    reg                              awlock0  ='b0; 
    reg [3:0]                        awcache0 ='b0; 
    reg [2:0]                        awprot0  ='b0;
    reg [3:0] 						 awqos0	  ='b0;
    reg                              awuser0  ='b0;
    reg [`D_AXI4_ID_WIDTH-1:0]       arid0    ='b0; 
    reg [`D_AXI4_ADDRESS_WIDTH-1:0]  araddr0  ='b0; 
    reg [3:0]                        arregion0='b0; 
    reg [7:0]                        arlen0   ='b0; 
    reg [2:0]                        arsize0  ='b0; 
    reg [1:0]                        arburst0 ='b0; 
    reg                              arlock0  ='b0; 
    reg [3:0]                        arcache0 ='b0; 
    reg [2:0]                        arprot0  ='b0;
    reg                              aruser0  ='b0;
	reg[3:0]                         arqos0   = 'b0;
    reg                              wlast0   ='b0;
    reg                              wuser0   ='b0;
    reg                              buser0   ='b0;
    reg                              ruser0   ='b0;

initial
    begin		
        for (i0=0; i0<(`D_AXI4_BURST_LENGHT); i0=i0+1)
		begin
			data0[i0] = 0;
		end

	    @(UP.MASTER_U0.ARESETn===0);
	    @(UP.MASTER_U0.ARESETn===1);
		#1;
       
        fork
            begin
                while (1)
                begin
                    `slv_bfm0.BfmWaitForWriteAddress(awid0 
                                                 ,awaddr0 
                                                 ,awregion0 
                                                 ,awlen0
                                                 ,awsize0
                                                 ,awburst0
                                                 ,awlock0
                                                 ,awcache0
                                                 ,awprot0
												 ,awqos0
												 ,awuser0);
												 
					for (l0=0; l0<(awlen0+1); l0=l0+1)
					begin
                    	`slv_bfm0.BfmWaitForWriteData(data0[l0], wstrb0[l0], wlast0, wuser0);
					end
                    `slv_bfm0.BfmSendWriteResponse(awid0, 'b0, buser0);
                end
            end
            begin
                while (1)
                begin
                    `slv_bfm0.BfmWaitForReadAddress(arid0 
                                               ,araddr0 
                                               ,arregion0 
                                               ,arlen0
                                               ,arsize0
                                               ,arburst0
                                               ,arlock0
                                               ,arcache0
                                               ,arprot0
											   ,arqos0
                                               ,aruser0);  
					for (j0=0; j0<(awlen0+1); j0=j0+1)
					begin
						if (j0==awlen0)
                    		`slv_bfm0.BfmSendReadResponse(arid0, 'b0, data0[j0], 1, ruser0);
						else
                    		`slv_bfm0.BfmSendReadResponse(arid0, 'b0, data0[j0], 0, ruser0);
					end
                end
            end
        join 
	end
endmodule

