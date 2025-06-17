"""
Test script for Face Classification API
"""

import requests
import base64
import json
from PIL import Image
import io

def image_to_base64(image_path):
    """Convert an image file to base64 string"""
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string

def test_api(base_url="http://localhost:8000"):
    """Test the Face Classification API"""
    print("Testing Face Classification API")
    print("=" * 50)
    
    # Test health check
    print("1. Testing health check...")
    try:
        response = requests.get(f"{base_url}/health")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test get classes
    print("\n2. Testing get classes...")
    try:
        response = requests.get(f"{base_url}/classes")
        print(f"   Status: {response.status_code}")
        print(f"   Available classes: {response.json()}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test prediction with a sample image
    print("\n3. Testing prediction...")
    
    # Create a simple test image if no real image is provided
    test_image_path = "/Users/gena/Documents/SuitsMe/test_queen_2.png"
    try:
        # Try to use an existing image first
        img = Image.open(test_image_path)
    except:
        # Create a simple test image
        print("   Creating test image...")
        img = Image.new('RGB', (200, 200), color='red')
        img.save(test_image_path)
    
    # Convert to base64
    base64_image = image_to_base64(test_image_path)
    
    # Test simple prediction
    print("   Testing simple prediction...")
    try:
        payload = {
            "image": base64_image,
            "return_details": False
        }
        response = requests.post(f"{base_url}/predict", json=payload)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test detailed prediction
    print("\n   Testing detailed prediction...")
    try:
        payload = {
            "image": base64_image,
            "return_details": True,
            "weights": {"hierarchical": 0.7, "centroid": 0.3}
        }
        response = requests.post(f"{base_url}/predict", json=payload)
        print(f"   Status: {response.status_code}")
        result = response.json()
        if result.get("success"):
            print(f"   Predicted class: {result.get('predicted_class')}")
            print(f"   Confidence: {result.get('confidence'):.3f}")
            if result.get("details"):
                details = result["details"]
                print(f"   Ensemble: {details['ensemble']['class']} ({details['ensemble']['confidence']:.3f})")
                print(f"   Hierarchical: {details['hierarchical']['class']} ({details['hierarchical']['confidence']:.3f})")
                print(f"   Centroid: {details['centroid']['class']} (distance: {details['centroid']['distance']:.3f})")
        else:
            print(f"   Error: {result.get('error')}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test top-k prediction
    print("\n   Testing top-3 predictions...")
    try:
        payload = {
            "image": base64_image,
            "top_k": 3
        }
        response = requests.post(f"{base_url}/predict", json=payload)
        print(f"   Status: {response.status_code}")
        result = response.json()
        if result.get("success") and result.get("top_predictions"):
            print("   Top 3 predictions:")
            for i, pred in enumerate(result["top_predictions"], 1):
                print(f"     {i}. {pred['class']}: {pred['confidence']:.3f}")
        else:
            print(f"   Error: {result.get('error')}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test simple endpoint
    print("\n   Testing simple endpoint...")
    try:
        payload = {
            "image": base64_image
        }
        response = requests.post(f"{base_url}/predict/simple", json=payload)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   Error: {e}")

if __name__ == "__main__":
    import sys
    
    # Allow custom base URL
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
    
    print(f"Testing API at: {base_url}")
    test_api(base_url) 