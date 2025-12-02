"""
Test script to check if Gemini Pro responds better to tool calling instructions
"""
import requests
import json

url = "http://localhost:8765/v1/chat/completions"

# Test with explicit tool request
payload = {
    "messages": [
        {
            "role": "user",
            "content": "use search tool and tell me if document with 2025-12-01 name exist"
        }
    ],
    "tools": [
        {
            "type": "function",
            "function": {
                "name": "search_documents",
                "description": "Search for documents in the user's AFFiNE workspace",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "The search query to find documents"
                        }
                    },
                    "required": ["query"]
                }
            }
        }
    ],
    "model": "gemini-2.5-pro",  # Try with Pro
    "stream": False
}

print("🧪 Testing Gemini 2.5 Pro with tool calling...")
print(f"Request: {json.dumps(payload, indent=2)}\n")

response = requests.post(url, json=payload)

print(f"Status: {response.status_code}")
print(f"Response:\n{json.dumps(response.json(), indent=2)}")
