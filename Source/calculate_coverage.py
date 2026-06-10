import os

def calculate_coverage(file_path):
    if not os.path.exists(file_path):
        print("Coverage file not found.")
        return

    total_lh = 0
    total_lf = 0
    file_coverage = []
    
    current_file = ""
    lh = 0
    lf = 0
    
    with open(file_path, 'r') as f:
        for line in f:
            if line.startswith('SF:'):
                current_file = line.split(':')[1].strip()
                lh = 0
                lf = 0
            elif line.startswith('LH:'):
                lh = int(line.split(':')[1])
                total_lh += lh
            elif line.startswith('LF:'):
                lf = int(line.split(':')[1])
                total_lf += lf
            elif line.startswith('end_of_record'):
                if lf > 0:
                    file_coverage.append((current_file, lh, lf))
    
    if total_lf == 0:
        print("No lines found in coverage file.")
        return

    print(f"{'File':<60} | {'LH':<5} / {'LF':<5} | {'%':<6}")
    print("-" * 80)
    for file, lh, lf in sorted(file_coverage, key=lambda x: x[2], reverse=True):
        percent = (lh / lf) * 100
        print(f"{file[:60]:<60} | {lh:<5} / {lf:<5} | {percent:>5.1f}%")

    percentage = (total_lh / total_lf) * 100
    print("-" * 80)
    print(f"TOTAL {'':<54} | {total_lh:<5} / {total_lf:<5} | {percentage:>5.1f}%")

if __name__ == "__main__":
    calculate_coverage('coverage/lcov.info')
