base=./

ifeq ("push","${MAKECMDGOALS}")
	debug?=no
else 
	debug?=yes
endif



all : deploy

mode:
	@if [ "yes" == "${debug}" ]; then echo "Mode Debug"; else echo "Mode Product"; fi

dep: mode

product:dep 
	@cd ${base} && docpad -e product run

web: dep
	@cd ${base} && docpad run

push: dep
	@cd ${base}
	@docpad -e deploy generate
	@git push -u origin master:project
	@git checkout staticmaster 
	@cp /home/ray/tmp/blog_out/* ./
	@git commit -am "publish blog $(date \"+%Y%m%d%H%M%s\")" && \
		git push
