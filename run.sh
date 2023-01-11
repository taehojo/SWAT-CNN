#!/bin/bash

# Define paths and filenames as variables
raw_file="./data/ADNI_HRC_V6_MAF1_N981_MAF5_RAW.raw"
all981_file="all981"
ID_file="ID"
DX_file="981_DX_all.csv"
DX_final="981-DX"
all_c1_file="all-all-c1.csv"
header_file="header"
number_rs_file="number-rs"
dir="/N/slate/tjo/v6"

# Function to copy and delete first line of file
process_raw_file() {
    cp "${raw_file}" "${all981_file}"
    sed -i '1d' "${all981_file}"
}

# Function to extract ID column
extract_ID() {
    awk -F' ' '{print $2}' "${all981_file}" > "${ID_file}"
}

# Function to extract DX information
extract_DX() {
    while read line ; do 
        grep "$line" "./data/Ages_DX_tjo.csv" >> "${DX_file}"
    done < "${ID_file}"
    awk -F',' '{print $1" "$3}' "${DX_file}" > "${DX_final}"
}

# Function to replace diagnosis information with numeric values
replace_diagnosis() {
    sed -i 's/CN-EMCI-AD/2/g' "${DX_final}" 
    sed -i 's/CN-EMCI-CN/1/g' "${DX_final}" 
}

# Function to extract specific columns from all981 file
extract_columns() {
    cut -d' ' -f 7- "${all981_file}" > t ; 
    mv t "${all_c1_file}"
}

# Function to create header file
create_header() {
    head -n 1 "${raw_file}" > "${header_file}"
    sed -i 's/ /\n/g' "${header_file}"
}

# Function to create number-rs file
create_number_rs() {
    tail -n +7 "${header_file}" > r2
    for i in {1..5398183}; do 
        echo "$i" 
    done > n
    paste -d' ' n r2 > "${number_rs_file}"
    rm r2 n
}

# Function to process files in batches
process_batch() {
    start_index=$1
    end_index=$2
    for i in $(seq $start_index $end_index); do 
        input_file="t-all-${i}.csv"
        output_file="${i}-$(($i+100000-1)).csv"
        ./script/py/v6.py 1 100001 "${dir}/981/5/${input_file}" > "${output_file}"
    done
}

# Call functions to process raw file
process_raw_file
extract_ID
extract_DX
replace_diagnosis
extract_columns
create_header
create_number_rs

# Process files in batches
process_batch 1 100000 1400000
process_batch 1400001 100000 2800000
process_batch 2800001 100000 4200000
process_batch 4200001 100000 5300000

# Process remaining files
./script/py/v6.py 1 100001 "${dir}/981/5/t-all-5300001.csv" >  5300001-5398183.csv
./script/py/v6.py 1 100001 "${dir}/981/prun/t-all-1.csv" > 1-100000.csv
./script/py/v6.py 1 100001 "${dir}/981/prun/t-all-100001.csv" > 100001-200000.csv
./script/py/v6.py 1 100001 "${dir}/981/prun/t-all-200001.csv" > 200001-300000.csv
./script/py/v6.py 1 100001 "${dir}/981/prun/t-all-300001.csv" > 300001-400000.csv
./script/py/v6.py 1 100001 "${dir}/981/prun/t-all-400001.csv" > 400001-446663.csv

for i in `seq 1 100000 5300000`; do 
    input_file="../1st/t-all-${i}.csv"
    output_file="${i}-$(($i+100000-1)).csv"
    ./script/py/v6.py 1 100001 "${input_file}" > "${output_file}" 
done
./script/py/v6.py 1 100001 "../1st/t-all-5300001.csv" >  5300001-5398183.csv

# Window=40
for j in {1..5300000..100000} ; do 
    for i in {1..2500}; do 
        echo "$j" 
    done > "${j}.a" 
done
for i in `seq 1 100000 5300000`; do 
    ./script/py/v6.py 2 100001 ${dir}/981/prun/t-all-${i}.csv $j.a > ${i}-$(($i+100000-1)).b ; 
done

