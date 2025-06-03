FROM docker.n8n.io/n8nio/n8n:latest
USER root

# Install system packages required for browser automation and OCR
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    firefox \
    webkit2gtk-4.1 \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-fra \
    tesseract-ocr-data-deu \
    tesseract-ocr-data-spa \
    tesseract-ocr-data-por \
    tesseract-ocr-data-rus \
    tesseract-ocr-data-chi_sim \
    tesseract-ocr-data-chi_tra \
    tesseract-ocr-data-jpn \
    tesseract-ocr-data-ara \
    imagemagick \
    ghostscript \
    python3 \
    py3-pip \
    build-base \
    vips-dev \
    && rm -rf /var/cache/apk/*

# Install glibc compatibility for task runner binary
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk && \
    apk add --force-overwrite glibc-2.35-r1.apk && \
    rm glibc-2.35-r1.apk

# Install Playwright
RUN npm install -g playwright@latest

# Install Python packages for OCR and image processing
RUN pip3 install --no-cache-dir --break-system-packages \
    pytesseract \
    Pillow \
    pdf2image

# Install other Node.js packages for image processing
RUN npm install -g \
    tesseract.js \
    jimp \
    pdf-poppler

# Set up proper directories and permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod 755 /home/node/.n8n

# Create n8n config (remove task runner disable settings)
RUN echo '{}' > /home/node/.n8n/config && \
    chown node:node /home/node/.n8n/config

# Verify installations
RUN node --version && npm --version

# Clean up build dependencies
RUN apk del build-base vips-dev

USER node

# Set environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/bin
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata/
