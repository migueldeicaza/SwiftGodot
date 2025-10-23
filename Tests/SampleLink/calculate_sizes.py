#!/usr/bin/env python3

"""
Script to calculate symbol sizes from nm output.
Reads the 'x' file which contains hex offsets and symbol names.
"""

import sys

def main():
    filename = 'x'

    prev_offset = None
    prev_line_data = None

    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split(None, 2)  # Split into at most 3 parts
            if len(parts) < 2:
                continue

            # Extract hex offset and convert to decimal
            hex_offset = parts[0]
            try:
                offset = int(hex_offset, 16)
            except ValueError:
                continue

            # Get the rest of the line (symbol type and name)
            symbol_info = ' '.join(parts[1:])

            # If we have a previous offset, calculate and print the size
            if prev_offset is not None:
                size = offset - prev_offset
                print(f"{size:8d}  {prev_line_data['hex']}  {prev_line_data['symbol']}")

            # Save current values for next iteration
            prev_offset = offset
            prev_line_data = {
                'hex': hex_offset,
                'symbol': symbol_info
            }

    # Handle the last symbol
    if prev_line_data:
        print(f"       ?  {prev_line_data['hex']}  {prev_line_data['symbol']} (last symbol - size unknown)")

if __name__ == '__main__':
    main()
