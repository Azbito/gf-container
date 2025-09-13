#!/bin/bash

echo $G"STARTING SERVER!"$W
echo -ne $B'[>         ] TicketServer       \r'$W
sleep 1
cd /root/gf_server/TicketServer/
chmod 777 *
./TicketServer -p 7777 &>/dev/null &
echo -ne $B'[->        ] GatewayServer       \r'$W
sleep 3
cd /root/gf_server/GatewayServer/
chmod 777 *
./GatewayServer &>/dev/null &
echo -ne $B'[-->       ] MissionServer       \r'$W
sleep 3
cd /root/gf_server/MissionServer/
chmod 777 *
./MissionServer &>/dev/null &
echo -ne $B'[--->      ] WorldServer101       \r'$W
sleep 3
cd /root/gf_server/WorldServer101/
chmod 777 *
./WorldServer101 &>/dev/null &
echo -ne $B'[---->     ] ZoneServer101       \r'$W
sleep 5
cd /root/gf_server/ZoneServer101/
chmod 777 *
./ZoneServer101 &>/dev/null &
echo -ne $B'[----->    ] WorldServer102       \r'$W
sleep 4
cd /root/gf_server/WorldServer102/
chmod 777 *
./WorldServer102 &>/dev/null &
echo -ne $B'[------>   ] ZoneServer102       \r'$W
sleep 5
cd /root/gf_server/ZoneServer102/
chmod 777 *
./ZoneServer102 &>/dev/null &
echo -ne $B'[------->  ] WorldServer109       \r'$W
sleep 4
cd /root/gf_server/WorldServer109/
chmod 777 *
./WorldServer109 &>/dev/null &
echo -ne $B'[--------> ] ZoneServer109       \r'$W
sleep 5
cd /root/gf_server/ZoneServer109/
chmod 777 *
./ZoneServer109 &>/dev/null &
echo -ne $B'[--------->] LoginServer       \r'$W
sleep 4
cd /root/gf_server/LoginServer/
chmod 777 *
./LoginServer &>/dev/null &

freemem=$(free -m | grep "Mem:" | awk '{print $4}')
echo $B"SERVER STARTED! ${Y}Memory Available: ${freemem} MB"${W}
