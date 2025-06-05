FROM docker.n8n.io/n8nio/n8n:latest
USER root

# Install system packages required for browser automation and OCR
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    firefox \
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
    && rm -rf /var/cache/apk/*

# Install Python packages for OCR and image processing
# Use --root-user-action=ignore to suppress the warning
RUN pip3 install --no-cache-dir --break-system-packages --root-user-action=ignore \
    pytesseract \
    Pillow \
    pdf2image

# Install Node.js packages GLOBALLY so task runners can find them
# This is the key fix - task runners need global access to these modules
RUN npm install -g \
    playwright@latest \
    tesseract.js \
    jimp \
    pdf-poppler

# Set up proper directories and permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod 755 /home/node/.n8n

# Create n8n config
RUN echo '{}' > /home/node/.n8n/config && \
    chown node:node /home/node/.n8n/config && \
    chmod 600 /home/node/.n8n/config

# Verify installations
RUN node --version && npm --version
RUN npm list -g tesseract.js || echo "tesseract.js check"

USER node

# Set environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/bin
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata/