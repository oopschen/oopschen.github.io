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
	@git push origin master:project
	@docpad -e deploy generate
	@git push -u origin master:project
	@git checkout staticmaster 
	@cp -r /home/ray/tmp/blog_out/* ./
	@ls ./ | grep -v "node_modules" | xargs git add
	@git commit -m "publish blog $(date \"+%Y%m%d%H%M%s\")" && \
		git push origin staticmaster:master
	@git checkout master
