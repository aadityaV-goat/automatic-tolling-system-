//////////////////////////////////////////////////////////////////////////////////
//
// Module: Toll_Controller.v
// Description: This is the brain of the toll system. It receives a vehicle ID,
//              checks the balance, and generates control signals for the gate
//              and a display (Green/Red lights). It operates as a simple
//              Finite State Machine (FSM).
//
//////////////////////////////////////////////////////////////////////////////////

module Toll_Controller(
    clk,
    reset,
    start_transaction,
    vehicle_id_in,
    balance_from_mem,
    gate_open,
    display_signal,
    transaction_status,
    transaction_done,
    mem_addr,
    mem_write_enable,
    data_to_mem
);
    input clk;
    input reset;
    input start_transaction;
    input [3:0] vehicle_id_in;
    input [7:0] balance_from_mem;

    output reg gate_open;
    output reg [1:0] display_signal;
    output reg [1:0] transaction_status;
    output reg transaction_done;
    output reg [3:0] mem_addr;
    output reg mem_write_enable;
    output reg [7:0] data_to_mem;

    localparam TOLL_AMOUNT = 8'd50;

    localparam S_IDLE = 3'b000;
    localparam S_READ_MEM = 3'b001;
    localparam S_WAIT_DATA = 3'b010; // New state to wait for sync read
    localparam S_CHECK_BALANCE = 3'b011;
    localparam S_SUCCESS = 3'b100;
    localparam S_FAIL = 3'b101;

    reg [2:0] state, next_state;

    // Combinational logic for next state calculation
    always @(*) begin
        next_state = state; // Default
        case(state)
            S_IDLE: if (start_transaction) next_state = S_READ_MEM;
            S_READ_MEM: next_state = S_WAIT_DATA;
            S_WAIT_DATA: next_state = S_CHECK_BALANCE;
            S_CHECK_BALANCE: begin
                if (balance_from_mem >= TOLL_AMOUNT)
                    next_state = S_SUCCESS;
                else
                    next_state = S_FAIL;
            end
            S_SUCCESS: next_state = S_IDLE;
            S_FAIL: next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end

    // Sequential logic for state and output registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            gate_open <= 1'b0;
            display_signal <= 2'b00;
            transaction_status <= 2'b00;
            transaction_done <= 1'b0;
            mem_addr <= 4'b0000;
            mem_write_enable <= 1'b0;
            data_to_mem <= 8'd0;
        end else begin
            state <= next_state;
            
            // Default assignments
            transaction_done <= 1'b0;
            mem_write_enable <= 1'b0;

            case(state)
                S_IDLE: begin
                    gate_open <= 1'b0;
                    display_signal <= 2'b00;
                    transaction_status <= 2'b00;
                end
                S_READ_MEM: begin
                    mem_addr <= vehicle_id_in;
                end
                S_WAIT_DATA: begin
                    // Do nothing, just wait for memory data to be valid
                end
                S_CHECK_BALANCE: begin
                    // Decision is made combinationally, no output change here
                end
                S_SUCCESS: begin
                    gate_open <= 1'b1;
                    display_signal <= 2'b01; // Green
                    transaction_status <= 2'b01; // Pass
                    transaction_done <= 1'b1;
                    mem_write_enable <= 1'b1;
                    data_to_mem <= balance_from_mem - TOLL_AMOUNT;
                end
                S_FAIL: begin
                    gate_open <= 1'b0;
                    display_signal <= 2'b10; // Red
                    transaction_status <= 2'b10; // Fail
                    transaction_done <= 1'b1;
                end
            endcase
        end
    end
endmodule
