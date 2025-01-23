build:
	hugo --minify

clean: 
	rm -r public

server: 
	hugo server --disableFastRender -D