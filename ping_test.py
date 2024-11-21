import os
import time
import shutil
import argparse
import ipaddress
import requests
import zipfile


# 构建基础URL
base_url = "172.20.60.6:9000"
use_https = False


def send_json_request(url, payload, headers=None, use_https=True):
    if headers is None:
        headers = {'Content-Type': 'application/json'}
    scheme = "https" if use_https else "http"
    full_url = f"{scheme}://{url}"
    try:
        response = requests.post(full_url, json=payload, headers=headers, stream=True)
        if response.headers.get('Content-Type') == 'application/zip':
            file_path = "downloaded_file.zip"
            with open(file_path, "wb") as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)
            print(f"ZIP file saved as '{file_path}'")
            return file_path
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return None

def unzip_file(zip_path, extract_to):
    os.makedirs(extract_to, exist_ok=True)
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
        print(f"Extracted all files to '{extract_to}'")
    return extract_to




if __name__ == "__main__":
    start_time = time.time()

    
    # 构建请求/api/vnode/execute/batch/接口的请求数据
    url = f"{base_url}/api/vnode/execute/batch/"
    request_data = [
        {"node_id": 3, "cmd_list": ["ping -i 0.001 -c 300000 fd01::6:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 2, "cmd_list": ["ping -i 0.001 -c 300000 fd01::2:9:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 11, "cmd_list": ["ping -i 0.001 -c 300000 fd01::9:8:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 88, "cmd_list": ["ping -i 0.001 -c 300000 fd01::3:1:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 10, "cmd_list": ["ping -i 0.001 -c 300000 fd01::5:0:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 100, "cmd_list": ["ping -i 0.001 -c 300000 fd02::1:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 101, "cmd_list": ["ping -i 0.001 -c 300000 fd02::2:1  > /var/log/frr/ping_log.txt",]},
        {"node_id": 102, "cmd_list": ["ping -i 0.001 -c 300000 fd02::1  > /var/log/frr/ping_log.txt",]},
    ]

    # 发送请求执行ping命令
    response_data = send_json_request(url, request_data, use_https=use_https)
    if response_data is None:
        print("Ping execution failed.")
        exit(1)
    else:
        print("Ping execution succeeded.")
    
    # 请求/api/tools/log/download（日志下载）
    node_ids=[2,3,10,11,88,100,101,102]
    print("Gathering ...")
    url = f"{base_url}/api/tools/log/download"
    request_data = {
        "nodes": node_ids,
        "volumes": "frr_log",
    }
    # 请求日志下载接口，下载各节点的frr_log
    snapshot_zip_path = send_json_request(url, request_data, use_https=use_https)
    if response_data is None:
        print("Table gathering failed.")
        exit(1)
    else:
        print("Table gathering succeeded.")

    # 解压下载好zip文件，该文件包含所有节点的frr_log挂载卷
    snapshot_dir = os.path.splitext(snapshot_zip_path)[0]
    if os.path.exists(snapshot_dir):
        shutil.rmtree(snapshot_dir)
    snapshot_dir = unzip_file(snapshot_zip_path, snapshot_dir)

    # ping日志文件路径
    ping_log_path = "downloaded_file/Sat3/frr_log/ping_log.txt"

    # 分析ping日志，获取断连次数和每次断连时间
    disconnection_count, disconnection_times = analyze_ping_log(ping_log_path)

    print(f"Ping was interrupted {disconnection_count} times.")
    for i, time_str in enumerate(disconnection_times):
        print(f"Disconnection {i + 1} at: {time_str}")

    end_time = time.time()
    print(f"Execution time: {end_time - start_time}s")
