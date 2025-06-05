FROM docker.n8n.io/n8nio/n8n:latest
USER root

# Install system packages required for browser automation and OCR
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    firefox \
    tesseract-ocr \
    tesseract-ocr-data-eng \
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
RUN npm install -g \
    playwright@latest \
    tesseract.js \
    jimp

# Set up proper directories and permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod 755 /home/node/.n8n

# Create n8n config with strict permissions
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