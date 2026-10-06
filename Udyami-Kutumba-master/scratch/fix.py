import re

def main():
    path = 'lib/features/ward/presentation/ward_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Fix the broken ones from the previous bad replacement
    text = re.sub(r'\$\{\(([A-Za-z0-9_]*)\.elapsedMilliseconds', r'${(sw\1.elapsedMilliseconds', text)
    
    # Fix totalSw which was skipped (since it didn't start with sw)
    text = re.sub(r'\$\{totalSw\.elapsedMilliseconds\} ms', r'${(totalSw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s', text)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

if __name__ == '__main__':
    main()
