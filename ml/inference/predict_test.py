import base64

def image_to_base64(image_path):
    """Convert an image file to base64 string"""
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string

if __name__ == "__main__":
    # change
    image_path = "./SuitsMe/test_queen_2.png"
    base64_image = image_to_base64(image_path)
    import requests
    import json

    url = "http://localhost:8000/predict/simple"
    headers = {"Content-Type": "application/json"}
    data = {"image": base64_image}

    response = requests.post(url, headers=headers, data=json.dumps(data))
    print("Status code:", response.status_code)
    try:
        print("Response:", response.json())
    except Exception:
        print("Response (non-JSON):", response.text)
