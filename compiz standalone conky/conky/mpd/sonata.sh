#!/bin/bash
sonata info > $HOME/conky/mpd/textsonata
if [ -f $HOME/conky/mpd/textsonata ]; then
	ARTIST=$(cat $HOME/conky/mpd/textsonata | grep Artista | cut -c 10-)
	ALBUM=$(cat $HOME/conky/mpd/textsonata | grep Álbum | cut -c 9-)
	echo "$ARTIST-$ALBUM.jpg" > $HOME/conky/mpd/text1
	IMAGE=$(cat $HOME/conky/mpd/text1)
	if [ -f "$HOME/.covers/$IMAGE" ]; then
		cp "$HOME/.covers/$IMAGE" "$HOME/conky/mpd/currentcover.png"
	else
		if [ -f "/$HOME/.covers/Varios artistas-$ALBUM.jpg" ]; then
			cp "$HOME/.covers/Varios artistas-$ALBUM.jpg" "$HOME/conky/mpd/currentcover.png"
		else
			cp "$HOME/conky/mpd/nocover.png" "$HOME/conky/mpd/currentcover.jpg"
		fi
	fi
else
	exit 1
fi

