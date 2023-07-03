def generate_acronym(text):
    words = text.split()
    acronym = ""
    for word in words:
        acronym += word[0].upper()
    return acronym

def main():
    input_filename = "idiom.txt"
    output_filename = "idiom.csv"

    try:
        with open(input_filename, 'r') as input_file, open(output_filename, 'w') as output_file:
            for line in input_file:
                line = line.strip()
                acronym = generate_acronym(line.replace("-", " "))
                output_file.write(line + "; " + acronym + "\n")
        
        print("Output berhasil disimpan di", output_filename)
    except FileNotFoundError:
        print("File tidak ditemukan.")

if __name__ == "__main__":
    main()
