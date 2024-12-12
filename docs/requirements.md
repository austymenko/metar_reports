# METAR Reports Processor

## Overview

A METAR (Meteorological Terminal Air Report) is a semi-standardized international format used by airports to report information about wind speeds, humidity, and weather conditions. This program parses a subset of these reports from a stream and maintains running aggregates.

## METAR Format

The general format of a METAR report is:
```
<ICAO Code> <Timestamp> <Wind Info>
```
Which breaks down into this:

### ICAO Code

- A string of upper-case ASCII letters
- At least one character long
- Terminated by a space

Examples:
- YYZ
- A
- LAX
- BIRK

Note: For this exercise, we're not concerned with verifying the validity of these codes. Parsing them is sufficient.

### Timestamp

Format: `<day of month><hours><minutes>Z`

Where:
- **day of month**: 2 digits (range: 01-31)
- **hours**: 2 digits (range: 00-23)
- **minutes**: 2 digits (range: 00-59)

### Wind Info

Format: `<direction><speed><gusts?><unit>`

Components:
- **direction**: 3 digits
- **speed**: 2-3 digits (minimum 00)
- **gusts**: 2 digits (optional, parsed as `G23`)
- **unit**: Either `KT` (knots) or `MPS` (meters per second)

Examples:
18027KT
180120MPS
01323G30MPS
Copy
## Example Reports
```
YYZ 122201Z 12023MPS
LAX 022355Z 09332G78KT
FR 110232Z 001100G12MPS
```

## Requirements

The program should:

1. Parse METAR format records as described above
    - Normalize all speeds to MPS (divide KT values by 2)
2. Read a stream of records, one per line
    - Maintain a running average wind speed per airport
    - Track the current wind speed of each airport
3. Generate a script to produce hundreds of thousands of random reports (one per line)
4. Process the entire stream without failure
5. Either:
    - Display a running tally, or
    - Print a final report after processing the entire stream

