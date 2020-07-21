
build: Dockerfile
	docker build -t testprox .

push: build
	docker tag testprox us.gcr.io/bookbook-271906/test-cron:0.0.3
	docker push us.gcr.io/bookbook-271906/test-cron:0.0.3
