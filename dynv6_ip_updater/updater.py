import requests
import sys
import time
import argparse

def get_public_ip():
    try:
        return requests.get("https://api.ipify.org").text
    except Exception as e:
        print(f"Error getting public IP: {e}")

def update_dynv6(ipv4, zone, token):
    url = f"https://dynv6.com/api/update?hostname={zone}&token={token}&ipv4={ipv4}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            print("Update successful.")
        else:
            print(f"Update failed with status code: {response.status_code}")
    except Exception as e:
        print(f"Error updating dynv6: {e}")

def main(zone, token):
    last_ip = None
    while True:
        current_ip = get_public_ip()
        if current_ip and current_ip != last_ip:
            update_dynv6(current_ip, zone, token)
            last_ip = current_ip
        time.sleep(10)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Dynv6 IP Updater')
    parser.add_argument('zone', type=str, help='Dynv6 Zone')
    parser.add_argument('token', type=str, help='Dynv6 Token')
    args = parser.parse_args()
    
    main(args.zone, args.token)

