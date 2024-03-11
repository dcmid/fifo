module fifo #(
  parameter WIDTH = 1,
  parameter DEPTH = 4  // must be power of 2
)(
  input   logic[WIDTH-1:0]  i_wdata,
  input   logic             i_wen,
  output  logic             o_full,

  output  logic[WIDTH-1:0]  o_rdata,
  input   logic             i_ren,
  output  logic             o_empty,

  input   logic             i_clk,
  input   logic             i_rst
);

  parameter PTR_WIDTH = $clog2(DEPTH);

  logic unsigned[PTR_WIDTH : 0] wpointer; // intentionally 1-bit "too long" for full/empty differentiation
  logic unsigned[PTR_WIDTH : 0] rpointer; // intentionally 1-bit "too long" for full/empty differentiation
  logic[WIDTH-1:0]              mem[0:DEPTH-1];

  // empty when pointers are identical
  assign o_empty = (wpointer == rpointer);
  // full when pointers are identical except for MSB
  assign o_full  = (wpointer[PTR_WIDTH - 1 : 0] == rpointer[PTR_WIDTH - 1 : 0]) && (wpointer[PTR_WIDTH] ^ rpointer[PTR_WIDTH]);

  always_ff @(posedge i_clk) begin : write_block
    if (i_rst == 1'b1) begin
        wpointer <= '0;
        for(int i = 0; i < DEPTH; i++) begin
          mem[i] <= '0;
        end
    end else begin
        if (i_wen && ~o_full) begin
            mem[wpointer[PTR_WIDTH-1:0]] <= i_wdata;
            wpointer <= wpointer + 1;
        end
    end
  end

  always_ff @(posedge i_clk) begin : read_block
    if(i_rst == 1'b1) begin
      rpointer <= '0;
      o_rdata  <= '0;
    end else begin
      if(i_ren && ~o_empty) begin
        o_rdata <= mem[rpointer[PTR_WIDTH-1:0]];
        rpointer <= rpointer + 1;
      end
    end
  end

endmodule

