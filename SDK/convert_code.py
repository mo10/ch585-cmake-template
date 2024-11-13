import os


def convert_to_utf8(file_path):
    try:
        with open(file_path, 'r', encoding='gbk') as f:
            content = f.read()
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Successfully converted: {file_path}")
    except Exception as e:
        print(f"Failed to convert {file_path}: {e}")


def convert_directory_to_utf8(directory):
    file_patterns = ('.s', '.c', '.h', '.ld', '.txt')
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            if filename.lower().endswith(file_patterns):
                file_path = os.path.join(dirpath, filename)
                convert_to_utf8(file_path)


def main():
    convert_directory_to_utf8('./')


if __name__ == '__main__':
    main()
