# WatchProc

## Introduction
WatchProc is a process monitoring CLI tool, which is built using Bash. Its sole purpose is to make monitoring any process easy.

---
## Overview
Monitoring a process is very important and there are a bunch of tools that make it possible. The reason why **WatchProc** is built is because there was a need for a customized and minimal interface, that would monitors only essential parameters.
WatchProc is a lightweight CLI tool, that provides real-time process information, making diagnosis while debugging and development easier. To get started, run the Bash script, provide the process ID or name along wit parameters such as the refresh interval.

---
## Functional Requirements
The initial version (v0.1.0), will consist of only core details and the future development will add bunch of more parameters.

### Core Features
- PID
- Process Name
- CPU %
- Memory % (or RSS)
- Process State (Running, Sleeping, Zombie, etc.)
- Command

### Extended Metrics
- User CPU Time
- Kernel CPU Time
- Total Threads
- Start Time
- Read Bytes (I/O)
- Write Bytes (I/O)
- Voluntary Context Switches
- Non-voluntary Context Switches
- Total Execution Runtime
- Number of Context Switches

---
## Options
```
-i <seconds> # refresh interval (default: 2)
-h # show help message
```

### Examples
```
watchproc <process_name | PID> [options]

watchproc cargo
watchproc 1234 -i 2 
```
