# 📋 Bill of Materials (BOM) - Electronics
## Atlas 6-DOF Robot Arm Control System

### 🔌 Main Controller Board

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| U1 | 1 | STM32F407VGT6 | ARM Cortex-M4F MCU, 168MHz | LQFP100 | ST Micro | 12.50€ | 12.50€ |
| U2 | 1 | LM2596S-5.0 | Buck Converter 24V→5V, 3A | TO-263 | TI | 3.20€ | 3.20€ |
| U3 | 1 | AMS1117-3.3 | LDO Regulator 5V→3.3V, 1A | SOT-223 | AMS | 0.45€ | 0.45€ |
| U4 | 1 | TPS73633 | Low-Noise LDO 3.3V, 400mA | SOT-23-5 | TI | 1.80€ | 1.80€ |
| U5 | 1 | MCP2551 | CAN Transceiver | SOIC-8 | Microchip | 1.25€ | 1.25€ |
| U6 | 1 | LAN8720A | Ethernet PHY | QFN-24 | Microchip | 2.90€ | 2.90€ |
| U7 | 1 | MAX6369 | External Watchdog | SOT-23-6 | Maxim | 2.15€ | 2.15€ |
| U8-U11 | 4 | ISO7241C | Quad Digital Isolator | SOIC-16W | TI | 3.40€ | 13.60€ |

### 🔋 Power Components

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| L1 | 1 | SRR1260-100M | Power Inductor 10µH, 3A | 12x12mm | Bourns | 1.85€ | 1.85€ |
| C1-C4 | 4 | GRM32ER71H106KA12L | Ceramic Cap 10µF, 50V | 1210 | Murata | 0.35€ | 1.40€ |
| C5-C20 | 16 | GRM188R71H104KA93D | Ceramic Cap 100nF, 50V | 0603 | Murata | 0.08€ | 1.28€ |
| C21-C24 | 4 | TAJB226K016RNJ | Tantalum Cap 22µF, 16V | 1210 | AVX | 0.65€ | 2.60€ |

### 🔗 Connectors & Interfaces

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| J1 | 1 | 1-1734742-0 | Power Input 24V | Screw Terminal | TE Conn | 2.40€ | 2.40€ |
| J2 | 1 | 5-146285-4 | CAN Bus Connector | RJ45 | TE Conn | 1.20€ | 1.20€ |
| J3 | 1 | USB-B-S-RA | USB Connector | USB-B | Amphenol | 0.85€ | 0.85€ |
| J4-J9 | 6 | 22-28-4363 | Motor Connectors 3-pin | Molex KK | Molex | 0.45€ | 2.70€ |
| J10-J15 | 6 | 22-28-4043 | Encoder Connectors 4-pin | Molex KK | Molex | 0.55€ | 3.30€ |

### 🛡️ Protection Components

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| D1-D8 | 8 | SMAJ24A | TVS Diode 24V | SMA | Littelfuse | 0.25€ | 2.00€ |
| F1-F3 | 3 | 0ZCG0050FF2E | PTC Fuse 500mA | 0603 | Bel Fuse | 0.15€ | 0.45€ |
| FB1-FB2 | 2 | BLM18PG471SN1D | Ferrite Bead 470Ω | 0603 | Murata | 0.12€ | 0.24€ |

### 🔧 Passive Components

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| R1-R20 | 20 | RC0603FR-0710KL | Resistor 10kΩ, 1% | 0603 | Yageo | 0.02€ | 0.40€ |
| R21-R30 | 10 | RC0603FR-071KL | Resistor 1kΩ, 1% | 0603 | Yageo | 0.02€ | 0.20€ |
| R31-R34 | 4 | RC0603FR-07120RL | Resistor 120Ω, 1% | 0603 | Yageo | 0.02€ | 0.08€ |

### 💎 Crystal & Timing

| Ref | Qty | Part Number | Description | Package | Supplier | Unit Price | Total |
|-----|-----|-------------|-------------|---------|----------|------------|-------|
| Y1 | 1 | ABM8G-25.000MHZ-4Y-T3 | Crystal 25MHz | 3.2x2.5mm | Abracon | 0.85€ | 0.85€ |
| Y2 | 1 | ABS07-32.768KHZ-T | Crystal 32.768kHz | 3.2x1.5mm | Abracon | 0.45€ | 0.45€ |

### 📊 Cost Summary

| Category | Subtotal |
|----------|----------|
| **Main Components** | 41.85€ |
| **Power Management** | 7.13€ |
| **Connectors** | 10.45€ |
| **Protection** | 2.69€ |
| **Passives** | 0.68€ |
| **Timing** | 1.30€ |
| **Subtotal** | **64.10€** |
| **PCB Manufacturing** | 25.00€ |
| **Assembly** | 35.00€ |
| **Testing** | 8.00€ |
| **Total per Board** | **132.10€** |

### 🏭 Manufacturing Partners

- **PCB**: JLCPCB (China) - 4-layer, HASL finish
- **Components**: Mouser Electronics (Europe)
- **Assembly**: Local SMT service (Montréal)
- **Testing**: In-house with custom test jig

### 📦 Alternative Components

| Primary | Alternative | Reason |
|---------|-------------|---------|
| STM32F407VGT6 | STM32F405RGT6 | Cost reduction (-30%) |
| LAN8720A | DP83848 | Better EMI performance |
| MCP2551 | TJA1050 | Automotive grade |

### 🔧 Assembly Notes

1. **Reflow Profile**: SAC305 lead-free solder
2. **Stencil**: 0.12mm stainless steel
3. **Pick & Place**: High-precision placement required for QFN packages
4. **Inspection**: AOI + manual inspection for critical components
5. **Testing**: In-circuit test + functional validation