import json

data = {}

with open("idiom.csv", "r") as file:
    for line in file:
        line = line.strip()
        parts = line.split("; ", 1)
        if len(parts) == 2:
            key, value = parts
            if value in data:
                data[value].append(key)
            else:
                data[value] = [key]
        else:
            print(f"Ignoring line: {line}")

# Save data in JSON format
with open("dict_json.json", "w") as json_file:
    json.dump(data, json_file, indent=4)

print("Data successfully saved in JSON format.")
