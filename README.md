# Computer ArchitectureII - Memory Hierarchy

This project was designed for the discipline of Computer Archtecture II - PUCRS

## TODO
- [ ] Propagation Time
- [ ] Cache L1
- [ ] Cache L2
- [ ] Benchmark tests

## **Introduction**

The main objective is design an Memory Herarchy based on two diferent levels of cache and an main memory.

## **Description**

### **Processor**

The Processor communicate with the memory hierarchy through address port, control port(define the memory access), state port(indicate if the information readed has already over), and the unidirectional port to receive the instructions. 
The signs from processor MUST go directly to the level just below the hierarchy memory. Each level will be responsible for generating the data address for the next level.

### **Cache**

Each cache level has a set of signals that report the operation result of reading, such as hit or miss signals. For each level, also sould be directed to control and address.

**The Cache level 1 have:**
- Direct Mapping;
- 4 lines;
- each block will have 4 words.
  
**The Cache level 2 have:**
- Associate Mapping;
- 8 lines;
- each block will have 8 words.
  

### **Instruction Memory**

The Instruction memory must be implemented through an ASM file containing a code executable by the processor. This code shall be described in order to verify the functionality of the memory hierarchy that is being implemented. For example, a program to test the instruction hierarchy must make several memory accesses, forcing some cases ocurring cache miss and cache hit, in order to exploit the spatial and temporal locality of the program.

### **Propagation delay**

Each level of the hierarchy memory must have an propagation delay, as following:
- Cache L1: same frequency of processor;
- Cache L2: Acess time of 2 clocks;
- Principal Memory: Acess time of 4 clocks.

