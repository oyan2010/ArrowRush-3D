import os
import struct
import zlib
import math

def create_png(width, height, draw_func):
    png = bytearray(b'\x89PNG\r\n\x1a\n')
    ihdr_data = struct.pack('!IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff
    png.extend(struct.pack('!I', len(ihdr_data)) + b'IHDR' + ihdr_data + struct.pack('!I', ihdr_crc))
    
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)
        for x in range(width):
            r, g, b, a = draw_func(x, y, width, height)
            raw_data.extend([r, g, b, a])
            
    idat_data = zlib.compress(bytes(raw_data), 9)
    idat_crc = zlib.crc32(b'IDAT' + idat_data) & 0xffffffff
    png.extend(struct.pack('!I', len(idat_data)) + b'IDAT' + idat_data + struct.pack('!I', idat_crc))
    
    iend_crc = zlib.crc32(b'IEND') & 0xffffffff
    png.extend(struct.pack('!I', 0) + b'IEND' + struct.pack('!I', iend_crc))
    
    return bytes(png)

def icon_drawer_2d(x, y, w, h):
    nx = (x / w) * 2 - 1
    ny = (y / h) * 2 - 1
    dist = math.sqrt(nx*nx + ny*ny)
    
    bg_radius = 0.85
    if dist > bg_radius:
        return 0, 0, 0, 0
        
    t = (ny + 1) / 2
    r_bg = int(248 * (1-t) + 241 * t)
    g_bg = int(250 * (1-t) + 245 * t)
    b_bg = int(252 * (1-t) + 249 * t)
    
    if dist > bg_radius - 0.04:
        alpha = int(255 * ((bg_radius - dist) / 0.04))
        return r_bg, g_bg, b_bg, max(0, min(255, alpha))
        
    ax = nx * 1.25
    ay = ny * 1.25
    
    rad = math.radians(-45)
    rx = ax * math.cos(rad) - ay * math.sin(rad)
    ry = ax * math.sin(rad) + ay * math.cos(rad)
    
    is_arrow = False
    if -0.22 < rx < 0.22 and -0.42 < ry < 0.32:
        is_arrow = True
    if ry < -0.12 and abs(rx) < (0.6 * (-0.12 - ry) / 0.42):
        is_arrow = True
        
    if is_arrow:
        return 61, 90, 254, 255 # Accent Royal Blue 2D Arrow
        
    return r_bg, g_bg, b_bg, 255

def main():
    base_dir = r"f:\Android\ArrowRush 3D\android\app\src\main\res"
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    for folder, sz in sizes.items():
        folder_path = os.path.join(base_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        png_bytes = create_png(sz, sz, icon_drawer_2d)
        
        for icon_name in ['ic_launcher.png', 'ic_launcher_round.png']:
            filepath = os.path.join(folder_path, icon_name)
            with open(filepath, 'wb') as f:
                f.write(png_bytes)
            print(f"Wrote {filepath} ({sz}x{sz})")

    assets_dir = r"f:\Android\ArrowRush 3D\assets\icons"
    os.makedirs(assets_dir, exist_ok=True)
    
    icon_256 = create_png(256, 256, icon_drawer_2d)
    icon_path = os.path.join(assets_dir, 'app_icon.png')
    with open(icon_path, 'wb') as f:
        f.write(icon_256)
    print(f"Wrote {icon_path} (256x256)")

if __name__ == '__main__':
    main()
