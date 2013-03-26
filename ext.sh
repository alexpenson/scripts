export filename=$(basename "$1")
export extension="${filename##*.}"
export filebase="${filename%.*}"
