import requests
import time
import os

# No need to load dotenv since we will prompt the user if values are missing

def get_env_variable(var_name, prompt_message):
    """
    Tries to get an environment variable's value.
    If not found, prompts the user for it.
    """
    value = os.getenv(var_name)
    if value is None:
        value = input(prompt_message)
    return value

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

def main():
    zone = get_env_variable("DYNV6_ZONE", "Please specify DYNV6_ZONE: ")
    token = get_env_variable("DYNV6_TOKEN", "Please specify DYNV6_TOKEN: ")
    
    last_ip = None
    while True:
        current_ip = get_public_ip()
        if current_ip and current_ip != last_ip:
            update_dynv6(current_ip, zone, token)
            last_ip = current_ip
        time.sleep(10)

if __name__ == "__main__":
    main()

