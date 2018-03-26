# bluenet

bluenet is a networking protocol for ComputerCraft that supports multiple LANs. Client computers send packets to "router" computers which route the packets to their respective destination. 

## Usage Documentation

### Client Setup
There is no daemon to run on the client. The only prerequisite to use bluenet is that the client announces itself to the router. This is accomplished using the `bluenet.announce_host()` function found in the client API. 

bluenet is fully API compatible with rednet. This means that converting an existing rednet program to use bluenet is very easy. Simply replace any references to `rednet` with `bluenet`. The program will still function as intended. When creating a new program, one can follow the existing rednet documentation, replacing any `rednet` references with `bluenet`

### Router Setup
The "router" computer should be configured with two modems. One functions as a LAN device, the other functions as a WAN device. The sides on which each respective device is place can be configured by modifying the options in `routed.lua`. When setting up the "router" computer, `routed.lua` should be made to start on launch. The "router" computer runs `routed` which monitors for incoming packets and routes them as described below. 

## Architecture and Inner Workings

### LAN Routing
This is accomplished using a simple routing table. When a packet is recieved on a router's "LAN" device, the router compares the destination of that packet with the routing table. If the destination is in the routing table, it simply forwards that packet to the destination computer back through the LAN device. However, if the destination is not in the local routing table, it "multicasts" the packet on the WAN device. All other routers on the WAN recieve the packet on their respective WAN devices. 

### WAN Routing
When a packet is recieved on a router's "WAN" device, the router compares the destination of that packet with the local routing table, again. If the destination is in the local routing table, it forwards the packet to the destination computer through the "LAN" device. However, if the destination is not in the local routing table, the router simply discards the packet. 

### Routing Table
The "router" maintains a routing table based on client announcements. A properly configured client will "announce" itself to the router on startup. When the router recieves the announcement packet, it adds that client to the routing table. Currently, the client will remain in the routing table as long as the router remains on. We are looking into ways to change this, and have some sort of "heartbeat" system that checks if clients are still alive, and removes them from the table if they are not. This is, however, more challenging than expected, and is in continued development.