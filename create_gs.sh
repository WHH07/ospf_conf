frr_conf_gs0="!
frr version 9.2-dev-my-manual-build
frr defaults traditional
hostname r101
!
interface eth0
  ipv6 ospf6 area 0.0.0.0
interface eth1
  ipv6 ospf6 area 0.0.0.0 
exit
!
router ospf6
  ospf6 router-id 10.10.10.101
  bfd all-interfaces
interface eth0
  ipv6 ospf6 bfd profile bfdd
interface eth1
  ipv6 ospf6 bfd profile bfdd
exit
!
end"

echo "$frr_conf_gs0" > gs_0/frr_conf/frr.conf


frr_conf_gs1="!
frr version 9.2-dev-my-manual-build
frr defaults traditional
hostname r102
!
interface eth0
  ipv6 ospf6 area 0.0.0.0
interface eth1
  ipv6 ospf6 area 0.0.0.0
interface eth2
  ipv6 ospf6 area 0.0.0.0
exit
!
router ospf6
  ospf6 router-id 10.10.10.102
  bfd all-interfaces
interface eth0
  ipv6 ospf6 bfd profile bfdd
interface eth1
  ipv6 ospf6 bfd profile bfdd
interface eth2
  ipv6 ospf6 bfd profile bfdd
exit
!
end"

echo "$frr_conf_gs1" > gs_1/frr_conf/frr.conf

frr_conf_gs2="!
frr version 9.2-dev-my-manual-build
frr defaults traditional
hostname r103
!
interface eth0
  ipv6 ospf6 area 0.0.0.0
interface eth1
  ipv6 ospf6 area 0.0.0.0 
exit
!
router ospf6
  ospf6 router-id 10.10.10.103
  bfd all-interfaces
interface eth0
  ipv6 ospf6 bfd profile bfdd
interface eth1
  ipv6 ospf6 bfd profile bfdd
exit
!
end"

echo "$frr_conf_gs2" > gs_2/frr_conf/frr.conf

for((i=0;i<=2;i++)); do
bfd_conf="bfd profile bfdd
  detect-multiplier 3
  receive-interval 100
  transmit-interval 100"
	echo "$bfd_conf" > gs_"$i"/frr_conf/bfdd.conf
done;

for((i=0;i<=2;i++)); do
zebra_conf="interface lo
ipv6 address fd00::$i:2/128
ip forwarding
ipv6 forwarding
log timestamp precision 6
log file /var/log/frr debug"
	echo "$zebra_conf" > gs_"$i"/frr_conf/zebra.conf
done;



