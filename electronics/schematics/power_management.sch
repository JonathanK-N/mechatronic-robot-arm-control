# Power Management Schematic - Atlas Robot Control Board
# Input: 24VDC ±10% (5A max)
# Outputs: 5VDC/3A, 3.3VDC/1A, 3.3VA/400mA
# Efficiency: >85% full load
# Protection: Overcurrent, overvoltage, thermal

## Main Power Input Section
J1: Terminal Block 24VDC Input
├── Pin 1: +24VDC (Red wire)
├── Pin 2: GND (Black wire)
└── Pin 3: Earth/Chassis (Green/Yellow)

F1: Fuse 5A Fast-Blow (Littelfuse 0451005.MRL)
├── Anode → J1 Pin 1 (+24V)
└── Cathode → D1 Anode

D1: TVS Diode 28V (SMBJ28A)
├── Anode → F1 Cathode
├── Cathode → GND
└── Function: Overvoltage protection

C1: Input Filter Capacitor 1000µF/35V
├── Positive → D1 Anode (+24V_FILT)
├── Negative → GND
└── ESR: <50mΩ @ 100kHz

L1: Common Mode Choke 10mH/5A
├── Pin 1 → +24V_FILT
├── Pin 2 → +24V_CLEAN
├── Pin 3 → GND
├── Pin 4 → GND
└── Function: EMI suppression

## 5V Buck Converter Section (3A)
U1: LM2596S-5.0 (Texas Instruments)
├── Pin 1 (VIN) → +24V_CLEAN
├── Pin 2 (OUT) → L2 Pin 1
├── Pin 3 (GND) → GND
├── Pin 4 (FB) → R1/R2 junction
└── Pin 5 (ON/OFF) → +24V_CLEAN (always on)

L2: Power Inductor 100µH/3A (Würth 744773110)
├── Pin 1 → U1 Pin 2
├── Pin 2 → +5V_OUT
└── Saturation current: 4.5A

D2: Schottky Diode SS34 (3A/40V)
├── Anode → GND
├── Cathode → U1 Pin 2
└── Function: Freewheeling diode

C2: Output Capacitor 220µF/16V (Low ESR)
├── Positive → +5V_OUT
├── Negative → GND
└── ESR: <20mΩ @ 100kHz

R1: Feedback Resistor 1kΩ (1%)
├── Terminal 1 → +5V_OUT
└── Terminal 2 → U1 Pin 4

R2: Feedback Resistor 1.24kΩ (1%)
├── Terminal 1 → U1 Pin 4
└── Terminal 2 → GND

F2: Fuse 3A (0451003.MRL)
├── Input → +5V_OUT
└── Output → +5V_SYSTEM

## 3.3V Linear Regulator Section (1A)
U2: AMS1117-3.3 (Advanced Monolithic Systems)
├── Pin 1 (GND) → GND
├── Pin 2 (OUT) → +3V3_OUT
├── Pin 3 (IN) → +5V_SYSTEM
└── Tab → GND (thermal pad)

C3: Input Capacitor 10µF/16V Tantalum
├── Positive → +5V_SYSTEM
├── Negative → GND
└── Location: <5mm from U2 Pin 3

C4: Output Capacitor 22µF/10V Tantalum
├── Positive → +3V3_OUT
├── Negative → GND
└── Location: <5mm from U2 Pin 2

F3: Fuse 1A (0451001.MRL)
├── Input → +3V3_OUT
└── Output → +3V3_SYSTEM

## 3.3V Analog LDO Section (400mA)
FB1: Ferrite Bead 600Ω@100MHz (Murata BLM18PG601SN1D)
├── Pin 1 → +3V3_SYSTEM
└── Pin 2 → +3V3_LDO_IN

U3: TPS73633 Ultra-Low Noise LDO (Texas Instruments)
├── Pin 1 (IN) → +3V3_LDO_IN
├── Pin 2 (GND) → AGND
├── Pin 3 (EN) → +3V3_LDO_IN (always enabled)
├── Pin 4 (NR) → C7 (noise reduction)
└── Pin 5 (OUT) → +3V3_ANALOG

C5: Input Capacitor 1µF/10V Ceramic X7R
├── Terminal 1 → +3V3_LDO_IN
├── Terminal 2 → AGND
└── Location: <2mm from U3 Pin 1

C6: Output Capacitor 2.2µF/10V Ceramic X7R
├── Terminal 1 → +3V3_ANALOG
├── Terminal 2 → AGND
└── Location: <2mm from U3 Pin 5

C7: Noise Reduction 10nF/16V Ceramic COG
├── Terminal 1 → U3 Pin 4
├── Terminal 2 → AGND
└── Function: Reduces output noise to 30µVrms

## Ground Management
AGND: Analog Ground Plane
├── Connection to GND via FB2 (ferrite bead)
├── Isolated copper pour for analog circuits
└── Star point connection at power entry

FB2: Ferrite Bead 120Ω@100MHz (Murata BLM18PG121SN1D)
├── Pin 1 → GND (digital ground)
├── Pin 2 → AGND (analog ground)
└── Function: Isolate analog/digital grounds

## Power Monitoring and Protection
U4: INA219 Current/Power Monitor (Texas Instruments)
├── Pin 1 (VIN+) → +24V_CLEAN
├── Pin 2 (VIN-) → R_SHUNT terminal 2
├── Pin 3 (GND) → GND
├── Pin 4 (VCC) → +3V3_SYSTEM
├── Pin 5 (SDA) → MCU I2C_SDA
├── Pin 6 (SCL) → MCU I2C_SCL
├── Pin 7 (ALERT) → MCU GPIO_ALERT
└── Pin 8 (A0/A1) → GND (I2C address 0x40)

R_SHUNT: Current Sense Resistor 0.1Ω/1W (Vishay WSL2512)
├── Terminal 1 → +24V_CLEAN
├── Terminal 2 → +24V_MONITORED
└── Function: 0.1V/A current sensing

## Status LEDs
LED1: Power Status (Green)
├── Anode → +5V_SYSTEM via R3 (470Ω)
├── Cathode → GND
└── Function: Indicates 5V rail active

LED2: System Status (Blue)
├── Anode → +3V3_SYSTEM via R4 (330Ω)
├── Cathode → MCU GPIO_STATUS
└── Function: MCU controlled status

LED3: Fault Status (Red)
├── Anode → +5V_SYSTEM via R5 (470Ω)
├── Cathode → MCU GPIO_FAULT
└── Function: Indicates system fault

## Thermal Management
TH1: Temperature Sensor DS18B20 (Dallas/Maxim)
├── Pin 1 (GND) → GND
├── Pin 2 (DQ) → MCU GPIO_TEMP via R6 (4.7kΩ pullup)
├── Pin 3 (VDD) → +3V3_SYSTEM
└── Function: Monitor board temperature

## Test Points
TP1: +24V Test Point
TP2: +5V Test Point  
TP3: +3V3 Test Point
TP4: +3V3_ANALOG Test Point
TP5: GND Test Point
TP6: AGND Test Point

## Power Supply Specifications
Input Specifications:
├── Voltage: 24VDC ±10% (21.6V - 26.4V)
├── Current: 5A maximum continuous
├── Ripple: <100mV pp (acceptable)
├── Transient: ±2V for 1ms (protected by TVS)
└── Connector: Phoenix Contact MKDS 1,5/3

Output Specifications:
+5V Rail:
├── Voltage: 5.0V ±2% (4.9V - 5.1V)
├── Current: 3A maximum
├── Ripple: <50mV pp @ full load
├── Load regulation: <1%
├── Line regulation: <0.5%
└── Efficiency: 87% @ full load

+3V3 Rail:
├── Voltage: 3.3V ±1% (3.267V - 3.333V)
├── Current: 1A maximum
├── Ripple: <20mV pp @ full load
├── Load regulation: <0.5%
├── Line regulation: <0.2%
└── Dropout: 1.2V typical

+3V3_ANALOG Rail:
├── Voltage: 3.3V ±0.5% (3.284V - 3.316V)
├── Current: 400mA maximum
├── Noise: 30µVrms (10Hz - 100kHz)
├── PSRR: 75dB @ 1kHz
├── Load regulation: <0.1%
└── Dropout: 200mV typical

## EMC Considerations
Input Filtering:
├── Common mode choke L1: 10mH
├── Differential mode: C1 (1000µF)
├── TVS protection: SMBJ28A
└── Fusing: 5A fast-blow

PCB Layout Guidelines:
├── Ground planes: Solid copper pour
├── Power traces: 2mm width minimum
├── Thermal vias: Under regulators
├── Keep-out zones: Around switching nodes
└── Decoupling: Close to IC pins

Safety Features:
├── Input fusing: Overcurrent protection
├── TVS diodes: Overvoltage protection  
├── Thermal monitoring: DS18B20 sensor
├── Current monitoring: INA219 IC
└── Enable/disable: Software controlled

This power management section provides clean, stable power rails for all system components while maintaining high efficiency and comprehensive protection.