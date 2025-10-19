#!/usr/bin/env python3
"""
App Icon Generator for DayPilot
Creates a simple, beautiful app icon using Material Icons style
No image subscriptions needed!
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    """Create app icon with gradient background and icon symbol"""
    
    # Icon size (Android requires 1024x1024 for adaptive icon)
    size = 1024
    
    # Create base image
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Define gradient colors (DayPilot brand colors)
    color1 = (99, 102, 241)   # #6366F1 - Primary (Indigo)
    color2 = (139, 92, 246)   # #8B5CF6 - Secondary (Purple)
    
    # Create gradient background
    for y in range(size):
        ratio = y / size
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # Draw white circle in center (represents app icon base)
    circle_size = int(size * 0.7)
    circle_x = (size - circle_size) // 2
    circle_y = (size - circle_size) // 2
    draw.ellipse(
        [circle_x, circle_y, circle_x + circle_size, circle_y + circle_size],
        fill='white'
    )
    
    # Draw icon symbol (checkmark + calendar style)
    # This represents productivity/tasks
    icon_size = int(size * 0.5)
    icon_x = (size - icon_size) // 2
    icon_y = (size - icon_size) // 2
    
    # Draw calendar outline
    rect_size = int(icon_size * 0.8)
    rect_x = icon_x + (icon_size - rect_size) // 2
    rect_y = icon_y + (icon_size - rect_size) // 2
    
    draw.rounded_rectangle(
        [rect_x, rect_y, rect_x + rect_size, rect_y + rect_size],
        radius=int(rect_size * 0.1),
        outline=color1,
        width=int(size * 0.04)
    )
    
    # Draw calendar header
    header_height = int(rect_size * 0.2)
    draw.rectangle(
        [rect_x, rect_y, rect_x + rect_size, rect_y + header_height],
        fill=color1
    )
    
    # Draw checkmark
    check_size = int(rect_size * 0.5)
    check_x = rect_x + (rect_size - check_size) // 2
    check_y = rect_y + header_height + (rect_size - header_height - check_size) // 2
    
    # Checkmark path
    check_width = int(size * 0.05)
    check_points = [
        (check_x, check_y + check_size // 2),
        (check_x + check_size // 3, check_y + check_size * 2 // 3),
        (check_x + check_size, check_y + check_size // 4)
    ]
    
    draw.line(
        [(check_points[0]), (check_points[1])],
        fill=color2,
        width=check_width
    )
    draw.line(
        [(check_points[1]), (check_points[2])],
        fill=color2,
        width=check_width
    )
    
    return img

def create_foreground_icon():
    """Create foreground icon for adaptive icon"""
    size = 1024
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    color1 = (99, 102, 241)
    color2 = (139, 92, 246)
    
    # Smaller icon for foreground
    icon_size = int(size * 0.6)
    icon_x = (size - icon_size) // 2
    icon_y = (size - icon_size) // 2
    
    # Draw calendar outline
    rect_size = int(icon_size * 0.9)
    rect_x = icon_x + (icon_size - rect_size) // 2
    rect_y = icon_y + (icon_size - rect_size) // 2
    
    draw.rounded_rectangle(
        [rect_x, rect_y, rect_x + rect_size, rect_y + rect_size],
        radius=int(rect_size * 0.12),
        fill='white'
    )
    
    # Calendar header
    header_height = int(rect_size * 0.25)
    draw.rounded_rectangle(
        [rect_x, rect_y, rect_x + rect_size, rect_y + header_height],
        radius=int(rect_size * 0.12),
        fill=color1
    )
    
    # Checkmark
    check_size = int(rect_size * 0.5)
    check_x = rect_x + (rect_size - check_size) // 2
    check_y = rect_y + header_height + (rect_size - header_height - check_size) // 2
    
    check_width = int(size * 0.06)
    check_points = [
        (check_x, check_y + check_size // 2),
        (check_x + check_size // 3, check_y + check_size * 2 // 3),
        (check_x + check_size, check_y + check_size // 4)
    ]
    
    draw.line([(check_points[0]), (check_points[1])], fill=color2, width=check_width)
    draw.line([(check_points[1]), (check_points[2])], fill=color2, width=check_width)
    
    return img

if __name__ == '__main__':
    # Create assets/icons directory if it doesn't exist
    os.makedirs('assets/icons', exist_ok=True)
    
    print("🎨 Generating DayPilot App Icon...")
    
    # Create main app icon
    icon = create_app_icon()
    icon.save('assets/icons/app_icon.png')
    print("✅ Created: assets/icons/app_icon.png")
    
    # Create foreground for adaptive icon
    foreground = create_foreground_icon()
    foreground.save('assets/icons/app_icon_foreground.png')
    print("✅ Created: assets/icons/app_icon_foreground.png")
    
    print("\n📱 App icons generated successfully!")
    print("\nNext steps:")
    print("1. Add flutter_launcher_icons to pubspec.yaml")
    print("2. Run: flutter pub add dev:flutter_launcher_icons")
    print("3. Add configuration to pubspec.yaml")
    print("4. Run: flutter pub run flutter_launcher_icons")
