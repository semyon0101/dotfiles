#!/usr/bin/env python
import hid
import sys

def set_goodix_haptic(path, intensity, click_force):
    try:
        dev = hid.device()
        dev.open_path(path.encode('utf-8'))
        
        # Установка интенсивности отдачи (Report ID: 9, Диапазон: 0-100)
        # Выравнивание пакета нулями до 9 байт: [ReportID, Value, 0, 0, 0, 0, 0, 0, 0]
        buf_intensity = [9, intensity] + [0] * 7
        dev.send_feature_report(buf_intensity)
        
        # Установка силы клика (Report ID: 8, Диапазон: 1-3)
        # Предполагаемое выравнивание до 8-9 байт (зависит от дескриптора)
        buf_force = [8, click_force] + [0] * 7
        dev.send_feature_report(buf_force)
        
        dev.close()
    except Exception as e:
        print(f"Failed to set haptic parameters: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <device_path> <intensity_0_100> <force_1_3>")
        sys.exit(1)
        
    set_goodix_haptic(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
