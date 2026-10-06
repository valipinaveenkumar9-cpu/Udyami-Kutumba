import json

try:
    with open('payloads/meeting_and_attendance/meeting_and_attendance_json.txt', 'r', encoding='utf-8') as f:
        data = f.read()
        # Find all occurrences of HTTP methods + paths
        import re
        apis = re.findall(r'(GET|POST|PUT|PATCH|DELETE)\s+(/[/\w{}?=&-]+)', data)
        for method, path in apis:
            print(f"{method} {path}")
except Exception as e:
    print("Error:", e)
