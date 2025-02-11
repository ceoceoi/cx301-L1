module mem_test (
    input logic clk, 
    output logic read, 
    output logic write, 
    output logic [4:0] addr, 
    output logic [7:0] data_in,     // data TO memory
    input  wire [7:0] data_out     // data FROM memory
);

// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking

// Monitor Results
initial begin
    $timeformat(-9, 0, " ns", 9);
    // SYSTEMVERILOG: Time Literals
    #40000ns $display("MEMORY TEST TIMEOUT");
    $finish;
end

// write_mem tasks
task write_mem(input [4:0] waddr, input [7:0] wdata, input bit dbug);
    @(negedge clk);
    read = 0;
    write = 1;
    addr = waddr;
    data_in = wdata;
    @(negedge clk);      
    write = 0;
    if (dbug == 1)
        $display("Write - Address:%d  Data:%h", waddr, wdata);
endtask

// read_mem task
task read_mem(input [4:0] raddr, output [7:0] rdata, input bit dbug);
    @(negedge clk);         
    write = 0;
    read  = 1;
    addr  = raddr;
    @(negedge clk);
    read = 0;
    rdata = data_out;    
    if (dbug == 1) 
        $display("Read  - Address:%d  Data:%h", raddr, rdata);
endtask

// add result print function
function void printstatus(input int status);
    if (status == 0)
        $display("Test PASSED");
    else
        $display("Test FAILED with %0d errors", status);
endfunction

initial begin: memtest
    int error_status = 0; // Declare error_status
    int i = 0;
   

    // Initialize signals
    read = 0;
    write = 0;
    addr = 0;
    data_in = 0;

    $display("Clear Memory Test");
    for (int i = 0; i < 32; i++) begin
        // Write zero data to every address location
        @(negedge clk);
        read = 0;
        write = 1;
        addr = i;
        data_in = 8'h00;

        if (debug)
            $display("Writing 0 to address %0d", i);
    end

    for (i = 0; i < 32; i++) begin 
        // Read every address location
        @(negedge clk);
        read = 1;        
        write = 0;
        addr = i;
        @(negedge clk);

        // check each memory location for data = 'h00
        if (data_out !== 8'h00) begin
            $display("Error at address %0d: Expected 0x%h, Found 0x%h", i, 8'h00, data_out);
            error_status++;
        end else if (debug) begin
            $display("Address %0d verified: Contains 0x%h", i, data_out);
        end
        read = 0;
    end

    // print results of test
    if (error_status == 0)
        $display("Data = Address Test");
    else
        $display("FAIL - %0d errors", error_status);
    
    for (int i = 0; i < 32; i++) begin
        // Write data = address to every address location
        @(negedge clk);
        read = 0;
        write = 1;
        addr = i;
        data_in = i;
    end
    for (int i = 0; i < 32; i++) begin
        // Read every address location
        @(negedge clk);
        read = 1;        
        write = 0;
        addr = i;
        @(negedge clk);

        // check each memory location for data = address
        if (data_out !== i) begin
            $display("Error at address %0d: Expected 0x%h, Found 0x%h", i, i, data_out);
            error_status++;
        end else if (debug) begin
            $display("Address %0d verified: Contains 0x%h", i, data_out);
        end
        read = 0;
    end

    // print results of test
    printstatus(error_status);
    $finish;
end

endmodule


