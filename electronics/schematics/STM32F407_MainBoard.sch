# STM32F407VGT6 Main Controller Board
# Atlas 6-DOF Robot Arm Control System
# Author: Jonathan Kakesa Nayaba - Polytechnique Montréal
# Company: Mechatronic Solution

## Schematic Overview
This is the main controller board schematic for the Atlas 6-DOF robot arm.
The board is based on the STM32F407VGT6 microcontroller running at 168MHz.

### Key Components:

#### Microcontroller
- STM32F407VGT6 (LQFP100 package)
- 168MHz ARM Cortex-M4F with FPU
- 1MB Flash, 192KB RAM, 64KB CCM RAM
- Hardware floating-point unit for real-time calculations

#### Power Management
- Input: 24VDC from main power supply
- LM2596 Buck converter: 24V → 5V (3A)
- AMS1117-3.3: 5V → 3.3V (1A) for MCU
- TPS73633: 3.3V → 3.3V LDO (400mA) for analog circuits

#### Communication Interfaces
- CAN Transceiver: MCP2551 (1Mbps)
- Ethernet PHY: LAN8720A (100Mbps)
- USB OTG: Full-speed device/host
- UART: 3x channels with RS485 transceivers

#### Motor Control Interfaces
- 6x PWM outputs for servo control
- 6x Encoder inputs (differential, 5V tolerant)
- 4x Analog inputs for current sensing
- Emergency stop input (hardware interrupt)

#### Sensor Interfaces
- I2C: MPU6050 IMU, temperature sensors
- SPI: Absolute encoders (14-bit resolution)
- ADC: 8x channels for analog sensors
- GPIO: 24x digital I/O with 5V tolerance

#### Protection & Safety
- TVS diodes on all external connections
- Fuses: 500mA (3.3V), 1A (5V), 3A (24V)
- Watchdog timer: Internal + external (MAX6369)
- Isolation: ISO7241C for CAN bus

### Pin Assignments:

#### High-Speed Timers (PWM Generation)
- TIM1_CH1 (PA8): Motor 1 PWM
- TIM1_CH2 (PA9): Motor 2 PWM  
- TIM1_CH3 (PA10): Motor 3 PWM
- TIM8_CH1 (PC6): Motor 4 PWM
- TIM8_CH2 (PC7): Motor 5 PWM
- TIM8_CH3 (PC8): Motor 6 PWM

#### Encoder Interfaces
- TIM2: Encoder 1 (PA0, PA1)
- TIM3: Encoder 2 (PA6, PA7)
- TIM4: Encoder 3 (PB6, PB7)
- TIM5: Encoder 4 (PA2, PA3)

#### Communication
- CAN1: PB8 (RX), PB9 (TX)
- USART1: PA9 (TX), PA10 (RX) - Debug
- USART2: PA2 (TX), PA3 (RX) - HMI
- SPI1: PA5 (SCK), PA6 (MISO), PA7 (MOSI) - Encoders
- I2C1: PB6 (SCL), PB7 (SDA) - Sensors

#### Safety & Control
- Emergency Stop: PC13 (EXTI13)
- System Enable: PC14 (Output)
- Status LED: PC15 (Output)
- Watchdog Feed: PD0 (Output)

### Design Notes:
1. All high-current traces are 2mm wide minimum
2. Analog and digital grounds separated with ferrite bead
3. Crystal oscillator has guard traces and ground plane
4. Decoupling capacitors: 100nF ceramic + 10µF tantalum per power rail
5. EMI filtering on all external connections

### PCB Specifications:
- 4-layer PCB: Signal/Ground/Power/Signal
- Dimensions: 100mm x 80mm
- Copper thickness: 35µm (1oz)
- Via size: 0.2mm drill, 0.4mm pad
- Minimum trace width: 0.1mm (signal), 0.5mm (power)

### Manufacturing Notes:
- Lead-free HASL finish
- Green solder mask
- White silkscreen
- Impedance control: 50Ω single-ended, 100Ω differential
- Assembly: SMT components on top side only