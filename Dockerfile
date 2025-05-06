FROM python:3.11-slim

ARG VERSION=dev
ARG REPO_URL="https://github.com/${GITHUB_REPOSITORY:-local/build}"
ARG GITHUB_REPOSITORY="local/build"

ENV NLTK_DATA=/usr/local/nltk_data \
    SETUPTOOLS_SCM_PRETEND_VERSION_FOR_LIB_ML=$VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir nltk && \
    mkdir -p /usr/local/nltk_data && \
    python -m nltk.downloader -d /usr/local/nltk_data punkt stopwords && \
    apt-get purge -y wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir scikit-learn && \
    pip install --no-cache-dir .


LABEL org.opencontainers.image.source=$REPO_URL \
      org.opencontainers.image.description="lib-ml container image" \
      org.opencontainers.image.licenses=MIT \
      org.opencontainers.image.version=$VERSION

CMD ["python", "-c", "import lib_ml, sys; print(lib_ml.__version__)"]

