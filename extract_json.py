import json
import re

with open('autoloads/GameData.gd', 'r', encoding='utf-8') as f:
    text = f.read()

match = re.search(r'var questions_db = (\{.*?\n\})', text, re.DOTALL)
if match:
    dict_str = match.group(1)
    # Convert integer keys to strings
    dict_str = re.sub(r'(\n\s*)(\d+):\s*\[', r'\1"\2": [', dict_str)
    try:
        data = eval(dict_str)
        with open('data/questions.json', 'w', encoding='utf-8', newline='\n') as out:
            json.dump(data, out, ensure_ascii=False, indent=4)
        print("JSON Extracted.")
    except Exception as e:
        print("Error eval:", e)
else:
    print("Could not find questions_db")
