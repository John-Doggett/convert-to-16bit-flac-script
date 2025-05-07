#! /bin/bash

if [[ -z "$1" || -z "$2" || "$1" == "$2" ]]; then
	echo "Convert higher bit flac files to 16 bit 44100hz."
	echo "Usage: $0 [input-directory] [output-directory]"
	exit 1
fi

# Directories
INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Temporary metadata file
TAGFILE="tags.txt"

# Loop over all .flac files in original/
for infile in "$INPUT_DIR"/*.flac; do
    [ -e "$infile" ] || continue  # Skip if no .flac files

    # Extract filename without path
    filename=$(basename "$infile")
    outfile="$OUTPUT_DIR/$filename"

    echo "Processing $filename ..."

    # Export metadata
    metaflac --export-tags-to="$TAGFILE" "$infile"

    # Convert audio with highest quality settings
    sox "$infile" -b 16 "$outfile" rate -v 44100 dither -s

    # Import metadata
    metaflac --remove-all-tags "$outfile"  # Clear default sox tags
    metaflac --import-tags-from="$TAGFILE" "$outfile"

    echo "Done: $outfile"
done

# Clean up
rm -f "$TAGFILE"

