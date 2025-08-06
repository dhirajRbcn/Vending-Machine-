# Vending-Machine-
Vending Machine RTL designed in Verilog and verified it with the help of Testbench
Project Overview
The Vending Machine is designed to simulate a real-life scenario where users insert coins to purchase items. The machine dispenses the item once the correct amount is received and provides change if necessary. This design uses FSM (Finite State Machine) principles for state transitions based on inputs.

Key Features:
Accepts coins of different denominations (e.g., ₹1, ₹2, ₹5).
Dispenses item when the required amount is reached.
Provides balance/change to the user if overpaid.
Synchronous design based on clock and reset.
FSM-based state transitions.

Files Description
design.v:
Contains the RTL (Register Transfer Level) description of the vending machine, designed using Verilog. It implements the logic for coin acceptance, item dispensing, and change return.

testbench.v:
A self-checking testbench that simulates various input sequences to verify the functional correctness of the vending machine design. Includes stimulus generation and output monitoring.

How to Run
Compile the design and testbench:
iverilog -o vending_machine_tb design.v testbench.v

Run the simulation:
vvp vending_machine_tb

(Optional) View waveform using GTKWave:
gtkwave dump.vcd

Skills Demonstrated
FSM Design & Implementation.
Writing Verification Testbenches.
Simulation using Icarus Verilog & GTKWave.
Digital Design Concepts (State Machines, Sequential Logic).

Future Enhancements
Implement parameterized vending amounts.
Integrate with a scoreboard for automated result checking.
Extend the design to handle multiple item selections.
