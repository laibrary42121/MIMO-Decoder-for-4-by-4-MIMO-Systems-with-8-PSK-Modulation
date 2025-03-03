# MIMO Decoder for 4x4 MIMO Systems with 8-PSK Modulation

## Project Overview
This project implements a **MIMO decoder** for a **4x4 MIMO system** using **8-PSK modulation**. The decoder is designed using a **4-best Sphere Decoding algorithm**, balancing decoding performance and computational efficiency. The system is implemented with **Verilog** for hardware design and **MATLAB** for algorithm simulation and performance evaluation.

## Background
MIMO (Multiple-Input Multiple-Output) systems are key technologies in modern wireless communications, enabling improved spectral efficiency by utilizing multiple antennas at both transmitter and receiver ends. Efficient MIMO detection algorithms are essential to achieve optimal performance in such systems. This project focuses on decoding the received signals from a **4x4 MIMO system**, ensuring reliable communication even under noisy channel conditions.

## Key Features
- Developed a **4-best Sphere Decoding algorithm** to search for the optimal transmitted symbol vector, significantly reducing computational complexity compared to exhaustive Maximum Likelihood (ML) detection.
- Implemented the decoder using **15-bit fixed-point representation** (5 integer bits + 10 fractional bits) to support hardware-friendly processing.
- Achieved a **bit error rate (BER)** of **10^-4** at **15.5 dB SNR**, matching the performance of ML detection, but with lower computational cost.

## Tools & Technologies
- **Verilog** (Hardware Implementation)
- **MATLAB** (Simulation & Performance Analysis)
- **8-PSK Modulation**
- **MIMO Systems**
- **Sphere Decoding Algorithm**
