VERSION=0.1.0

build: Dockerfile
	docker build -t testprox .

push: build
	docker tag testprox us.gcr.io/bookbook-271906/test-cron:$(VERSION)
	docker push us.gcr.io/bookbook-271906/test-cron:$(VERSION)
