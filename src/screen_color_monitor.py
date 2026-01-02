#!/usr/bin/env python3
"""
Real-Time Screen Color Monitor for Hyprland
Samples screen content and extracts dominant colors dynamically
"""

import subprocess
import io
import colorsys
from PIL import Image
import numpy as np
from gi.repository import GLib


class ScreenColorMonitor:
    """
    Monitors screen content and extracts dominant colors in real-time.
    Samples center region of screen at configurable intervals.
    """

    def __init__(self, callback, update_interval=0.5, throttle_threshold=15):
        """
        Initialize screen color monitor.

        Args:
            callback: Function to call with new color (receives hex color string)
            update_interval: Seconds between samples (default: 0.5s for 2 FPS)
            throttle_threshold: Minimum RGB distance to trigger update (default: 15)
        """
        self.callback = callback
        self.update_interval = update_interval
        self.throttle_threshold = throttle_threshold
        self.last_color = None
        self.timer_id = None
        self.enabled = False

        # Screen dimensions (will be detected from hyprctl)
        self.monitor_width = 1920
        self.monitor_height = 1080
        self._detect_screen_size()

    def _detect_screen_size(self):
        """Detect screen resolution from hyprctl"""
        try:
            result = subprocess.run(
                ['hyprctl', 'monitors', '-j'],
                capture_output=True,
                timeout=1.0,
                text=True
            )

            if result.returncode == 0:
                import json
                monitors = json.loads(result.stdout)
                if monitors:
                    # Use first monitor for now
                    self.monitor_width = monitors[0]['width']
                    self.monitor_height = monitors[0]['height']
                    print(f"ScreenColorMonitor: Detected screen size: {self.monitor_width}x{self.monitor_height}")
        except Exception as e:
            print(f"ScreenColorMonitor: Could not detect screen size, using defaults: {e}")

    def start(self):
        """Start periodic screen sampling"""
        if self.enabled:
            print("ScreenColorMonitor: Already running")
            return

        self.enabled = True
        # Convert seconds to milliseconds for GLib
        interval_ms = int(self.update_interval * 1000)
        self.timer_id = GLib.timeout_add(interval_ms, self._sample_and_update)
        print(f"ScreenColorMonitor: Started (sampling every {self.update_interval}s)")

        # Do immediate first sample
        GLib.idle_add(self._sample_and_update)

    def stop(self):
        """Stop sampling"""
        if not self.enabled:
            return

        self.enabled = False
        if self.timer_id:
            GLib.source_remove(self.timer_id)
            self.timer_id = None
        print("ScreenColorMonitor: Stopped")

    def toggle(self):
        """Toggle sampling on/off"""
        if self.enabled:
            self.stop()
            return False
        else:
            self.start()
            return True

    def is_enabled(self):
        """Check if sampling is currently enabled"""
        return self.enabled

    def trigger_immediate_sample(self):
        """Force immediate sample (called on Hyprland events)"""
        if self.enabled:
            GLib.idle_add(self._sample_and_update)

    def _sample_and_update(self):
        """Capture screen region and extract color"""
        if not self.enabled:
            return False  # Stop timer

        try:
            # Calculate center 10% region geometry
            sample_w = int(self.monitor_width * 0.10)
            sample_h = int(self.monitor_height * 0.10)
            cx = self.monitor_width // 2
            cy = self.monitor_height // 2

            geometry = f"{cx - sample_w//2},{cy - sample_h//2} {sample_w}x{sample_h}"

            # Capture screenshot using grim
            result = subprocess.run(
                ['grim', '-g', geometry, '-t', 'png', '-'],
                capture_output=True,
                timeout=0.5
            )

            if result.returncode != 0:
                print(f"ScreenColorMonitor: grim capture failed")
                return True  # Continue timer

            # Load image and extract average color
            img = Image.open(io.BytesIO(result.stdout)).convert('RGB')
            color_array = np.array(img)
            avg_color = tuple(color_array.mean(axis=(0,1)).astype(int))

            # Throttle: only update if color changed significantly
            if self._should_update(avg_color):
                self.last_color = avg_color

                # Convert to hex
                hex_color = '#{:02x}{:02x}{:02x}'.format(*avg_color[:3])

                # Trigger callback with new color
                self.callback(hex_color)

        except subprocess.TimeoutExpired:
            print("ScreenColorMonitor: Capture timeout")
        except Exception as e:
            print(f"ScreenColorMonitor: Error sampling: {e}")

        return True  # Continue timer

    def _should_update(self, new_color):
        """
        Check if color changed enough to warrant update.
        Uses Euclidean distance in RGB space.
        """
        if self.last_color is None:
            return True

        # Calculate RGB distance
        distance = sum((a - b) ** 2 for a, b in zip(new_color, self.last_color)) ** 0.5
        return distance > self.throttle_threshold


class HybridColorProcessor:
    """
    Processes sampled colors with hybrid complementary + contrast approach.
    Ensures colors are both vibrant (complementary) and readable (high contrast).
    """

    @staticmethod
    def process_color(sampled_hex, background_hex='#000000', min_contrast_ratio=4.5):
        """
        Process sampled screen color using hybrid approach.
        Ensures clock color contrasts with the SAMPLED SCREEN COLOR (not config background).

        Args:
            sampled_hex: Hex color from screen sample
            background_hex: Ignored (kept for compatibility)
            min_contrast_ratio: Minimum contrast ratio to ensure (default: 4.5 for AA compliance)

        Returns:
            Processed hex color (complementary with contrast ensured against screen)
        """
        # Convert sampled color to RGB
        sampled_rgb = HybridColorProcessor._hex_to_rgb(sampled_hex)

        # Calculate screen luminance
        screen_luminance = HybridColorProcessor._calculate_luminance(sampled_rgb)

        # Get HSV of sampled color
        r, g, b = [x / 255.0 for x in sampled_rgb]
        h, s, v = colorsys.rgb_to_hsv(r, g, b)

        # Calculate complementary hue (180 degrees)
        h_comp = (h + 0.5) % 1.0

        # Adjust value (brightness) based on screen luminance to ensure contrast
        # Dark screen → bright clock, Bright screen → dark clock
        if screen_luminance < 0.5:
            # Dark screen detected - make clock BRIGHT
            v_target = 0.95  # Very bright
            s_target = max(0.6, s)  # Keep saturation decent
        else:
            # Bright screen detected - make clock DARK
            v_target = 0.3  # Dark but not black
            s_target = max(0.7, s)  # Keep saturation high for visibility

        # Create final color with complementary hue and adjusted brightness
        r_final, g_final, b_final = colorsys.hsv_to_rgb(h_comp, s_target, v_target)
        final_rgb = (int(r_final * 255), int(g_final * 255), int(b_final * 255))

        # Verify contrast ratio
        contrast = HybridColorProcessor._calculate_contrast_ratio(final_rgb, sampled_rgb)

        # If still not enough contrast, force to pure white or black
        if contrast < min_contrast_ratio:
            if screen_luminance < 0.5:
                # Dark screen - force white
                final_rgb = (255, 255, 255)
            else:
                # Bright screen - force black
                final_rgb = (0, 0, 0)

        final_hex = '#{:02x}{:02x}{:02x}'.format(*final_rgb)
        return final_hex

    @staticmethod
    def _hex_to_rgb(hex_color):
        """Convert hex color to RGB tuple (0-255 range)"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    @staticmethod
    def _calculate_luminance(rgb):
        """Calculate relative luminance for contrast checking (ITU-R BT.709)"""
        r, g, b = [x / 255.0 for x in rgb]
        return 0.2126 * r + 0.7152 * g + 0.0722 * b

    @staticmethod
    def _calculate_contrast_ratio(rgb1, rgb2):
        """Calculate WCAG contrast ratio between two RGB colors"""
        lum1 = HybridColorProcessor._calculate_luminance(rgb1)
        lum2 = HybridColorProcessor._calculate_luminance(rgb2)

        lighter = max(lum1, lum2)
        darker = min(lum1, lum2)

        return (lighter + 0.05) / (darker + 0.05)
