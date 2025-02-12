module mem_test (
    input  logic clk,
    output logic read,
    output logic write,
    output logic [4:0] addr,
    output logic [7:0] data_in,  // data TO memory
    input  wire  [7:0] data_out  // data FROM memory
);
    // SYSTEMVERILOG: timeunit and timeprecision specification
    timeunit 1ns;
    timeprecision 1ns;

    // SYSTEMVERILOG: new data types - bit, logic
    bit debug = 1;      // flag to control display messages
    logic [7:0] rdata;  


    initial begin
        $timeformat(-9, 0, " ns", 9);
        // SYSTEMVERILOG: Time Literals
        #40000ns $display("MEMORY TEST TIMEOUT");
        $finish;
    end

    //updated
    task write_mem(input [4:0] waddr, input [7:0] wdata, input bit dbug);
        @(negedge clk);    
        read = 0;          
        write = 1;         
        addr = waddr;      
        data_in = wdata;   
        @(negedge clk);    
        write = 0;         
        if (dbug == 1)     
            $display("Write - Address:%d Data:%h", waddr, wdata);
    endtask

    //updated
    task read_mem(input [4:0] raddr, output [7:0] rdata, input bit dbug);
        @(negedge clk);   
        write = 0;        
        read = 1;          
        addr = raddr;     
        @(negedge clk);    
        read = 0;          
        rdata = data_out; 
        if (dbug == 1)     
            $display("Read - Address:%d Data:%h", raddr, rdata);
    endtask

    //updated regarding to the task
    function void printstatus(input int status);
        if (status == 0)
            $display("Test PASSED");
        else
            $display("Test FAILED with %0d errors", status);
    endfunction

    
    initial begin: memtest
        int error_status = 0;  
        read = 0;
        write = 0;
        addr = 0;
        data_in = 0;

        $display("Clear Memory Test");
        
        
        for (int i = 0; i < 32; i++) begin
            write_mem(i, 0, debug); 
        end

        
        for (int i = 0; i < 32; i++) begin
            read_mem(i, rdata, debug);  
            error_status += checkit(i, rdata, 8'h00);  
        end
        
        printstatus(error_status); 
        
        $display("Testing data equal to address");
        
        
        for (int i = 0; i < 32; i++) begin
            write_mem(i, i, debug);  // Write address value to each address
        end

        
        for (int i = 0; i < 32; i++) begin
            read_mem(i, rdata, debug);  
            error_status += checkit(i, rdata, i);  
        end
        
        printstatus(error_status);  // Report final results
        $finish;
    end

   
    function int checkit(input [4:0] addr, input [7:0] data, input [7:0] expected);
        if (data !== expected) begin
            $display("ERROR: Address %0d: Got %h, Expected %h", addr, data, expected);
            return 1;
        end
        return 0;
    endfunction

endmodule

