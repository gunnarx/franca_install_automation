section Downloading Franca examples
#download "$EXAMPLES_URL" "$EXAMPLES_MD5"
#step Checking MD5 sum for FRANCA EXAMPLES
#md5_check EXAMPLES "$downloaded_file"
#mv "$downloaded_file" "$ECLIPSE_WORKSPACE_DIR" || die "Could not move examples file to workspace"

section Downloading Franca repository for examples
cd "$HOME"
cd "$ECLIPSE_WORKSPACE_DIR"
git clone https://github.com/franca/franca franca
cd "$MYDIR"
