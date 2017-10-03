#!/bin/bash

# The mnemonics below are defined in cmd_control.go, and expounded on in 9361_funcs.go, and map to C functions in ad9361_api.c.
RXLO 915000000      aka ad9361_set_rx_lo_freq
RXSF 30000000       aka ad9361_set_rx_sampling_freq
RXBW 30000000       aka ad9361_set_rx_rf_bandwidth
GNMD 0              aka ad9361_set_rx_gain_control_mode
RXGN 20             aka ad9361_set_rx_rf_gain
QUAD 1              aka ad9361_set_rx_quad_track_en_dis
QUAD?               aka ad9361_get_rx_quad_track_en_dis
DCBLOCK 1           aka ad9361_set_rx_bbdc_track_en_dis
DCBLOCK?            aka ad9361_get_rx_bbdc_track_en_dis

# CW-Signal values:
rx_lo_freq=915
rx_samp_freq=61440000
rx_rf_bandwidth=30000000
rx1_gc_mode=0
rx1_rf_gain=20

# Basic setup to view a sine wave input through the ILA:
rx_lo_freq=900
rx_samp_freq=60000000
rx_rf_bandwidth=30000000

# Basic setup for aquisition:
Si5324-10GEth-Setup
poke 0x43C10000 0xB00B
poke 0x43C10004 0x1
poke 0x43C10008 0x11223344
poke 0x43C1000C 0x1

# Collecting a fixed amount of packets (need over 2 million for a full capture):
sudo tshark -i eth1 -c 10 -w test.pcap

# Converting the packet contents of a PCAP file to text:
sudo tshark -r test.pcap -Tfields -e data > output.txt

# Splitting the output text file to 32-bit words:
sed -e "s/.\{4\}/&,/g" -e "s/.\{10\}/&\n/g" < output.txt > unprocessed_data.txt

# Removing extraneous new lines and commas:
sed -e "s/.$//" -e "/^$/d" < unprocessed_data.txt > processed_data.txt

# Combined string with comma delimiter for long-term processing:
sudo tshark -i eth1 -c 10 -w test.pcap && sudo tshark -r test.pcap -Tfields -e data > output.txt && sed -e "s/.\{4\}/&,/g" -e "s/.\{10\}/&\n/g" < output.txt > unprocessed_data.txt && sed -e "s/.$//" -e "/^$/d" < unprocessed_data.txt > processed_data.txt

# Combined string with no delimiter and new line after each 16-bit sample for long-term processing:
sudo tshark -i eth1 -c 1000 -w test.pcap && sudo tshark -r test.pcap -Tfields -e data > output.txt && sed -e "s/.\{4\}/&\n/g" < output.txt > processed_data.txt

# Combined string with no delimiter, no new line after each packet, a "0x" prepend, and new line after each 16-bit sample for long-term processing:
sudo tshark -i eth1 -c 1000 -w test.pcap && sudo tshark -r test.pcap -Tfields -e data > output.txt && sed -e "s/.$//" -e "s/.\{4\}/&\n/g" < output.txt > unprocessed_data.txt && sed -e 's/^/0x/' < unprocessed_data.txt > processed_data.txt
