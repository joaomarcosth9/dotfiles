import os
import sys
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

def get_mp4_files(root_path):
    for root, _, files in os.walk(root_path):
        for file in files:
            if file.lower().endswith('.mp4'):
                yield os.path.join(root, file)

def get_duration(path):
    cmd = [
        'ffprobe', '-v', 'error', '-select_streams', 'v:0',
        '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1',
        path
    ]
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
        return float(output)
    except Exception:
        return 0.0

def format_duration(total_seconds):
    hours = int(total_seconds // 3600)
    minutes = int((total_seconds % 3600) // 60)
    seconds = int(total_seconds % 60)
    return f"{hours:02d}h{minutes:02d}m{seconds:02d}s"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <diretorio>")
        sys.exit(1)
    path = sys.argv[1]
    if not os.path.isdir(path):
        print("O caminho fornecido não é um diretório válido.")
        sys.exit(1)

    files = list(get_mp4_files(path))
    total_seconds = 0.0

    with ThreadPoolExecutor(max_workers=8) as executor:  # ajuste max_workers conforme sua CPU
        futures = {executor.submit(get_duration, f): f for f in files}
        for future in as_completed(futures):
            total_seconds += future.result()

    print(f"Total: {format_duration(total_seconds)}")

