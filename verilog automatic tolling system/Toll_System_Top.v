//////////////////////////////////////////////////////////////////////////////////
//
// Module: Toll_System_Top.v
// Description: This top-level module instantiates and connects the 
//              Toll_Controller and Balance_Memory modules to form the complete
//              automatic toll collection system.
//
//////////////////////////////////////////////////////////////////////////////////

module Toll_System_Top(
    clk,
    reset,
    start_transaction,
    vehicle_id_in,
    gate_open,
    display_signal,
    transaction_status,
    transaction_done
);
    input clk;
    input reset;
    input start_transaction;
    input [3:0] vehicle_id_in;

    output gate_open;
    output [1:0] display_signal;
    output [1:0] transaction_status;
    output transaction_done;

    // Internal wires for connecting the modules
    wire [7:0] balance_from_mem;
    wire [3:0] mem_addr_wire;
    wire mem_write_enable_wire;
    wire [7:0] data_to_mem_wire;

    // Instantiate the Controller
    Toll_Controller controller (
        .clk(clk),
        .reset(reset),
        .start_transaction(start_transaction),
        .vehicle_id_in(vehicle_id_in),
        .balance_from_mem(balance_from_mem),
        .gate_open(gate_open),
        .display_signal(display_signal),
        .transaction_status(transaction_status),
        .transaction_done(transaction_done),
        .mem_addr(mem_addr_wire),
        .mem_write_enable(mem_write_enable_wire),
        .data_to_mem(data_to_mem_wire)
    );

    // Instantiate the Memory
    Balance_Memory memory (
        .clk(clk),
        .addr(mem_addr_wire),
        .data_in(data_to_mem_wire),
        .write_enable(mem_write_enable_wire),
        .data_out(balance_from_mem)
    );

endmodule

