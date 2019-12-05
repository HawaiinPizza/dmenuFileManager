CD(){
	#ls  --group-directories-first -S --color
	Choice='...'
	while [  "$Choice" != "." ] 
	do
		clear
		if [ -z "$(ls)" ]; then
			echo ''
		else
			lsd --group-dirs
		fi
		pwd
		Folders="...\n$(find -L .   -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*')\n...."
		Choice="$(printf "$Folders" | sort | sed 's/\..//' | slmenu -b -i )"
		cd "$Choice"
	done


}

