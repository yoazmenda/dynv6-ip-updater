import requests
import time
from dotenv import load_dotenv
import os

load_dotenv()

def get_public_ip():
    try:
        return requests.get("https://api.ipify.org").text
    except Exception as e:
        print(f"Error getting public IP: {e}")

def update_dynv6(ipv4):
    zone = os.getenv("DYNV6_ZONE")
    token = os.getenv("DYNV6_TOKEN")
    url = f"https://dynv6.com/api/update?hostname={zone}&token={token}&ipv4={ipv4}"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print("Update successful.")
        else:
            print(f"Update failed with status code: {response.status_code}")
    except Exception as e:
        print(f"Error updating dynv6: {e}")

def main():
    last_ip = None
    while True:
        current_ip = get_public_ip()
        if current_ip and current_ip != last_ip:
            update_dynv6(current_ip)
            last_ip = current_ip
        time.sleep(10)

if __name__ == "__main__":
    main()

