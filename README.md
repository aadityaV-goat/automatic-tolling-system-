# automatic-tolling-system-
1. Theory of Operation 
The project simulates an automatic toll gate using digital logic.
When a vehicle arrives, the testbench sends a vehicle ID to the system.
A controller (FSM) receives the ID and starts the transaction.
The FSM reads the vehicle balance from the memory.
The balance is compared with the fixed toll amount.
If balance is sufficient:
Gate is opened
Green light is turned ON
Toll amount is deducted from balance
Updated balance is written back to memory
If balance is insufficient:
Gate remains closed
Red light is turned ON
Balance is not updated
After completing the process, the system returns to idle state and waits for the next vehicle.

2. Core Concepts & Theory
2.1 Modular Design
Instead of designing the entire system as one massive, complex piece of code, we used a modular approach. The system is broken down into smaller, self-contained, and reusable hardware blocks (modules). This makes the design easier to understand, debug, and manage. Our system is divided into three main hardware modules: the Memory, the Controller, and a Top-level module to connect them.
2.2 Finite State Machine (FSM)
A transaction is a process with a clear sequence of steps: wait for a car, check its balance, make a decision, and take action. A Finite State Machine (FSM) is the perfect digital circuit for managing such processes. An FSM is a model that can be in one of a finite number of "states." It moves from one state to another based on its current state and external inputs. For our toll booth, the FSM acts as the control unit, ensuring that each step of the transaction happens in the correct order.
2.3 Language Choice: Verilog
The entire design and simulation, from the hardware modules to the testbench, is implemented purely in Verilog.

Module Descriptions:
Balance_Memory.v (The Database): This module acts as a simple Random Access Memory (RAM). It contains an array of registers where each location stores the balance of a specific vehicle. The Vehicle ID is used as the "address" to look up or update the corresponding balance.
Toll_Controller.v (The Brain): This is the most critical module and contains the FSM. It receives the Vehicle ID, coordinates with the Balance_Memory to fetch the balance, compares it to the toll amount, and makes the final decision. Based on this decision, it generates the output signals for the gate and the display.
Toll_System_Top.v (The Motherboard): This module doesn't contain any logic itself. Its only job is to instantiate (create copies of) the controller and memory modules and connect them with wires, just like a motherboard connects a CPU and RAM.
testbench.v (The Simulator): This is a Verilog file used purely for testing. It simulates the real world by generating the clock signal, sending Vehicle IDs (as if a QR code was scanned), and monitoring the outputs to verify that our design works as expected.

