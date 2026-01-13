//////////////////////////////////////////////////////////////////////////////////
//
// Module: Balance_Memory.v
// Description: This module acts as a simple database (RAM) to store the
//              prepaid balance for a fixed number of vehicles. The vehicle ID
//              is used as the address to access the balance.
//
//////////////////////////////////////////////////////////////////////////////////

module Balance_Memory #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    input write_enable,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Memory array: 2^ADDR_WIDTH entries, each DATA_WIDTH bits wide
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

    // Pre-load memory with some initial values for the testbench
    initial begin
        mem[0] = 100;
        mem[1] = 40;  // Test Case 2: Insufficient balance
        mem[2] = 200; // Test Case 1: Sufficient balance
        mem[3] = 75;
        mem[4] = 50;
        mem[5] = 120;
    end

    // Synchronous read/write logic
    always @(posedge clk) begin
        // Read operation: Output the data at the given address.
        // The result will be available on the next clock cycle.
        data_out <= mem[addr];

        // Write operation
        if (write_enable) begin
            mem[addr] <= data_in;
        end
    end

endmodule

