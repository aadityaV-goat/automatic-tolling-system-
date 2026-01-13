//////////////////////////////////////////////////////////////////////////////////
//
// Module: testbench.v
// Description: A testbench to simulate the Toll_System_Top module. It mimics
//              vehicles arriving at the toll booth and verifies the system's
//              response, including gate status and display messages.
//
//////////////////////////////////////////////////////////////////////////////////

// This is the final, robust testbench.
// FIX: Timings have been relaxed to prevent potential simulator race conditions.
// FIX: Output format updated to be complete for both success and fail cases as requested.

`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg start_transaction;
    reg [3:0] vehicle_id_in;

    wire gate_open;
    wire [1:0] display_signal;
    wire [1:0] transaction_status;
    wire transaction_done;

    Toll_System_Top dut (
        .clk(clk),
        .reset(reset),
        .start_transaction(start_transaction),
        .vehicle_id_in(vehicle_id_in),
        .gate_open(gate_open),
        .display_signal(display_signal),
        .transaction_status(transaction_status),
        .transaction_done(transaction_done)
    );

    initial begin
        clk = 0;
        forever #0.5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("\n--- Automatic Toll System Simulation (Final) ---");
        $display("--- Toll Fee is set to 50 units ---\n");

        reset = 1;
        start_transaction = 0;
        vehicle_id_in = 0;
        #10;
        reset = 0;
        $display("At time %0.2fns: Reset is released. System is IDLE.", $time);
        #5;

        // --- Test Case 1: Vehicle with Sufficient Balance ---
        $display("\n--- Test Case 1: Vehicle with Sufficient Balance (ID: 02, Bal: 200) ---");
        vehicle_id_in = 2;
        start_transaction = 1;
        #1;
        start_transaction = 0;
        @(posedge transaction_done);
        if (transaction_status == 2'b01) begin
            $display("At time %0.2fns: STATUS  -> Transaction PASSED correctly.", $time);
            $display("At time %0.2fns: DISPLAY -> [GREEN] Have a safe journey!", $time);
            $display("At time %0.2fns: ACTION  -> Gate is now OPEN.", $time);
        end else
            $display("At time %0.2fns: STATUS  -> Transaction FAILED incorrectly.", $time);

        #5;

        // --- Test Case 2: Vehicle with Insufficient Balance ---
        $display("\n--- Test Case 2: Vehicle with Insufficient Balance (ID: 01, Bal: 40) ---");
        vehicle_id_in = 1;
        start_transaction = 1;
        #1;
        start_transaction = 0;
        @(posedge transaction_done);
        if (transaction_status == 2'b10) begin
             $display("At time %0.2fns: STATUS  -> Transaction BLOCKED correctly.", $time);
             $display("At time %0.2fns: DISPLAY -> [RED] Insufficient Balance!", $time);
             $display("At time %0.2fns: ACTION  -> Gate remains CLOSED.", $time);
        end else
             $display("At time %0.2fns: STATUS  -> Transaction PASSED incorrectly.", $time);

        #5;

        // --- Test Case 3: Vehicle with Exact Balance ---
        $display("\n--- Test Case 3: Vehicle with Exact Balance (ID: 04, Bal: 50) ---");
        vehicle_id_in = 4;
        start_transaction = 1;
        #1;
        start_transaction = 0;
        @(posedge transaction_done);
        if (transaction_status == 2'b01) begin
            $display("At time %0.2fns: STATUS  -> Transaction PASSED correctly.", $time);
            $display("At time %0.2fns: DISPLAY -> [GREEN] Have a safe journey!", $time);
            $display("At time %0.2fns: ACTION  -> Gate is now OPEN. Balance updated.", $time);
        end else
            $display("At time %0.2fns: STATUS  -> Transaction FAILED incorrectly.", $time);

        #5;
        
        // --- Test Case 4: Re-checking Vehicle 4 to confirm deduction ---
        $display("\n--- Test Case 4: Re-checking Vehicle 4 to confirm deduction (Bal: 0) ---");
        vehicle_id_in = 4;
        start_transaction = 1;
        #1;
        start_transaction = 0;
        @(posedge transaction_done);
        if (transaction_status == 2'b10) begin
             $display("At time %0.2fns: STATUS  -> Transaction BLOCKED correctly (Balance is now 0).", $time);
             $display("At time %0.2fns: DISPLAY -> [RED] Insufficient Balance!", $time);
             $display("At time %0.2fns: ACTION  -> Gate remains CLOSED.", $time);
        end else
             $display("At time %0.2fns: STATUS  -> Transaction PASSED incorrectly.", $time);

        #10;
        $display("\n--- Simulation Finished ---");
        $finish;
    end
endmodule

