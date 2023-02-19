build:
	docker build --tag kaize:latest --file docker/app/Dockerfile.prod .

save:
	docker save kaize:latest | gzip > _build/kaize_latest.tar.gz

copy:
	scp _build/kaize_latest.tar.gz $(to):~/kaize/kaize_latest.tar.gz

load:
	ssh $(to) docker load --input ./kaize/kaize_latest.tar.gz

deliver: save copy load

stop:
	ssh $(to) docker stop kaize || true

start:
	ssh $(to) docker run -it --env-file=./kaize/.env --rm --name kaize --detach kaize start

restart: stop start

deploy: build deliver restart

logs:
	ssh $(to) docker logs kaize --follow
