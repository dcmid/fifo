`include "../hdl/fifo.sv"

module fifo_tb;
  logic clk;
  logic rst;

  localparam WIDTH = 4;
  localparam DEPTH = 8;

  logic[WIDTH-1:0]  wdata;
  logic             wen;
  logic             full;
  logic[WIDTH-1:0]  rdata;
  logic             ren;
  logic             empty;

  int               count;

  fifo #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .i_wdata(wdata),
    .i_wen(wen),
    .o_full(full),

    .o_rdata(rdata),
    .i_ren(ren),
    .o_empty(empty),

    .i_clk(clk),
    .i_rst(rst)
  );

  task write_fifo;
    input [WIDTH-1:0] data;
    begin
      wdata <= data;
      wen   <= 1'b1;
      @(posedge clk);
      wen   <= 1'b0;
    end
  endtask

  task read_fifo;
    begin
      ren   <= 1'b1;
      @(posedge clk);
      ren   <= 1'b0;
    end
  endtask

  localparam CLK_PERIOD = 10;
  always #(CLK_PERIOD/2) clk=~clk;

  initial begin
      $dumpfile("fifo_tb.vcd");
      $dumpvars(0, fifo_tb);
  end

  initial begin
    wdata <= '0;
    wen   <= 1'b0;
    ren   <= 1'b0;
    clk   <= 1'b0;
    rst   <= 1'b0;

    //reset
    #(CLK_PERIOD*3)
    rst   <= 1'b1;

    #(CLK_PERIOD*3)
    rst   <= 1'b0;

    repeat(20) @(posedge clk);

    count = 0;
    while(~full) begin
      write_fifo(count);
      count = count + 1;
    end

    repeat(5) @(posedge clk);

    while(~empty) begin
      read_fifo();
    end

    repeat(5) @(posedge clk);

    $finish(2);
  end

endmodule