dlcache () {
	if [ ! -f "$(basename $1)" ]; then
		curl -L -O "$1"
	fi
}
