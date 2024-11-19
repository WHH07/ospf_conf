#for((i=0;i<=99;i++)); do
#	mkdir Sat"${i}"
#done;

#for((i=0;i<=2;i++)); do
#        mkdir gs_"${i}"
#done;
:<<block
for((i=0;i<=99;i++)); do
	mkdir Sat"${i}"/frr_conf
	mkdir Sat"${i}"/frr_log
done;

for((i=0;i<=2;i++)); do
        mkdir gs_"${i}"/frr_conf
	mkdir gs_"${i}"/frr_log
done;
block

for((i=0;i<=99;i++)); do
frr_conf="!
frr version 9.2-dev-my-manual-build
frr defaults traditional
hostname r$((i+1))
!
interface eth0
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd
interface eth1
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd
interface eth2
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd
interface eth3
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd
interface eth4
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd
interface eth5
  ipv6 ospf6 area 0.0.0.0
  ipv6 ospf6 bfd 
exit
!
router ospf6
  ospf6 router-id 10.10.10.$((i+1))
exit
!
end"

	echo "$frr_conf" > Sat"$i"/frr_conf/frr.conf
done;

for((i=0;i<=99;i++)); do
bfd_conf="bfd profile bfdd
  detect-multiplier 3
  receive-interval 100
  transmit-interval 100"
	echo "$bfd_conf" > Sat"$i"/frr_conf/bfdd.conf
done;

for((i=0;i<=99;i++)); do
# 求商
	((quotient = i / 10))
# 求余数
	((remainder = i % 10))
zebra_conf="interface lo
  ipv6 address fd00::$quotient:$remainder:1/128
ip forwarding
ipv6 forwarding
log timestamp precision 6
log file /var/log/frr debug"
	echo "$zebra_conf" > Sat"$i"/frr_conf/zebra.conf
done;




