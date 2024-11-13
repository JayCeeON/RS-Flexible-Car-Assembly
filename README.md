# Automated Assembly Process of a Chevrolet SS Lumina 2004

This project simulates the automated final assembly process of a Chevrolet SS Lumina 2004 using ABB industrial robots and RobotStudio software. The primary goal is to automate the attachment of wheels, doors, trunk, and hood to the vehicle’s preassembled chassis and body.

## Project Overview

The assembly process is divided into several stages:
1. **Reception of the Car Body**: The preassembled chassis with seats and body structure is positioned in the assembly cell.
2. **Wheel Installation**: Robots pick and mount the wheels using a pneumatic screwdriver.
3. **Final Body Assembly**: The robots position the doors, hood, and trunk.
4. **Completion**: The assembled vehicle exits the cell for final adjustments by human operators.

## Video Demonstration

For a detailed view of the assembly process, watch the demonstration video below:

![Automated Assembly Process Video](./path_to_video.mp4)

## Key Components

- **ABB IRB 4600 Robots**: Two robots, one on each side of the vehicle, handle tasks such as picking and placing components and tightening screws.
- **Dual Tool Design**: Each robot is equipped with a dual tool—one for lifting (using the Ixtur MAP-120R magnet) and one for screwing (OnRobot Screwdriver).
- **Conveyor System**: The main conveyor transports the vehicle through the assembly stages, while additional conveyors bring individual components (doors, trunk, hood) to the robots.

## Safety Features

A laser barrier system ensures operator safety. When an intrusion is detected, the robots halt immediately to prevent accidents. This emergency stop feature is implemented using TRAP routines in RAPID programming language.

## Assembly Process

1. **Body and Component Positioning**: The robots use the magnet tool to pick and place each component in the designated area.
2. **Variable Wheel Assembly**: Depending on the wheel type (standard, sport, or truck), the robots follow a different screwing pattern and heights. The parameters are dynamically set for each wheel type, improving flexibility.
3. **Continuous Cycle Operation**: The cell is designed to operate in a continuous cycle, with each robot returning to its initial position after completing a vehicle.

## Implementation

The project was implemented in RobotStudio, utilizing the RAPID programming language to define tool data, work objects, and control logic. The main controller coordinates with secondary controllers to synchronize robot movements, conveyor actions, and component positioning.

## Components

- **Dual Tool System**: Supports handling and screwing tasks.
- **External Axis Track**: Provides extended range for the robots to move along the assembly line.
- **Safety Laser Barriers**: Detect operator presence and trigger emergency stops.

## Future Improvements

Potential enhancements for this system include:
- Implementing continuous movement on the main conveyor to reduce idle time.
- Integrating IoT sensors for real-time monitoring and maintenance.
- Adding machine learning algorithms to optimize robot trajectories and predict maintenance needs.


