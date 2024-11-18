#for ((i=0; i<=98; i++)); do
#    cp Sat99/frr_conf/daemons Sat"$i"/frr_conf/daemons
#done

for ((i=0; i<=2; i++)); do
    cp Sat99/frr_conf/daemons gs_"$i"/frr_conf/daemons
done
