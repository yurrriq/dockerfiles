DOCKERFILE := "yurrriq/lilypond"

build:
	docker build -t ${DOCKERFILE} .
run:
	docker run -it ${DOCKERFILE}
