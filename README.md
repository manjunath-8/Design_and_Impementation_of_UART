# Design and Impementation of UART
## Abstract
The project focuses on the comprehensive understanding and practical realization of UART functionality, essential for serial communication in embedded systems. This industry project, undertaken for Semiksha Semiconductors, involved specific requirements that guided the design process.

The UART system is constructed with several critical components, including the Divisor Latch Register (DLR), Transmit Data Register (TDR), Received Data Register (RDR), Line Status Register (LSR), Modem Control Register (MCR), Modem Status Register (MSR), and various control and status registers such as the Interrupt Enable Register (IER), Interrupt Identification Register (IIR), and Line Control Register (LCR). Each component's functionality, access mechanisms, and bit configurations are meticulously detailed to ensure robust communication.

Clock generation and control are integral to the UART system, leveraging a programmable baud generator to derive the necessary bit clock from an input clock signal. The system supports oversampling, enhancing the accuracy of data transmission and reception. The baud generator's configuration, particularly the divisor latch register (DLR), is crucial for setting the desired baud rate and ensuring synchronized communication.

The implementation includes finite state machines (FSM) for both the transmitter and receiver, demonstrating the sequential process of data handling. Transmitter and receiver results, along with loopback mode operations, are provided to validate the system's performance and reliability.

The design was simulated in Xilinx and implemented on the Arty7 FPGA board using VIO. The design was first tested with a single Arty7 board in loopback mode and then with two Arty7 boards, one transmitting and the other receiving. This project not only illustrates the theoretical aspects of UART design but also emphasizes practical implementation, offering valuable insights into serial communication for embedded systems.

## Repository Structure
### UART 
This directory contains the main modules of the UART design. These modules typically include:
1. **UART**
   - Controls the overall UART operation, manages data flow between the transmitter and receiver, and interfaces with other system components.
2. **UART_tb**
   - This directory includes the test bench modules used for verifying the functionality of the UART design. Test benches simulate various scenarios to ensure the UART operates correctly under different conditions.
3. **Clock Generator**
   - Generates the required baud rate clock signal used by the UART transmitter and receiver.
4. **Transmitter**
   - This module handles the transmission of data from the system to external devices.
5. **Transmitter Buffer**
   - Buffers data to be transmitted in FIFO mode.
6. **Transmit Data Register (TDR)**
   -Holds data to be transmitted in Non-FIFO mode.
7. **Receiver**
   - This module manages the reception of data from external devices into the system. It includes:
8. **Receiver Buffer**
   - Buffers data received in FIFO mode.
9. **Received Data Register (RDR)**
   -Holds data received in Non-FIFO mode.

### Results
This directory contains the outcomes of the UART project, including:

1. **Hardware Arty7 Implementation:** 
   - Documentation, configuration files, and any necessary resources for the UART design implemented on the Arty7 FPGA board.
2. **Simulation of the Design:**
   - Results and logs from simulations conducted during the design process, showcasing the UART's performance in various test cases.

### UART_FPGA
When the hardware input and output ports of an FPGA are insufficient, we can use Virtual Input/Output (VIO) ports. VIO allows us to provide virtual inputs to the FPGA and receive virtual outputs from it. The following steps outline the implementation of VIO, as demonstrated in the video:

## Steps to Implement VIO

1. **Setup the VIO Core**
   - Integrate the VIO core into your FPGA design using the FPGA design software.
   - Select the VIO core from the IP catalog and add it to your design.

2. **Configure the VIO Core**
   - Configure the VIO core parameters according to your requirements.
   - Set the number of virtual inputs and outputs, their data widths, and any other necessary settings.

3. **Connect the VIO Core to the Design**
   - Connect the virtual inputs and outputs from the VIO core to the appropriate signals in your FPGA design.
   - This might involve linking them to internal signals, registers, or other components within the design.

4. **Generate the Bitstream**
   - After configuring and connecting the VIO core, generate the FPGA bitstream.
   - This process compiles your design and prepares it for programming onto the FPGA.

5. **Program the FPGA**
   - Load the generated bitstream onto the FPGA.
   - This step involves physically programming the FPGA with your design, including the VIO core.

6. **Interact with VIO via Software**
   - Use the FPGA design software's VIO interface to interact with the virtual inputs and outputs.
   - Manually set input values and observe output values in real-time, aiding in debugging and verification of your design.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
