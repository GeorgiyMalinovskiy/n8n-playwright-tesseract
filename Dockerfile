FROM docker.n8n.io/n8nio/n8n:latest
USER root

# Install system packages required for browser automation and OCR
# Avoid installing build-base and vips-dev globally to prevent conflicts
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
    && rm -rf /var/cache/apk/*

# Install Python packages for OCR and image processing
RUN pip3 install --no-cache-dir --break-system-packages \
    pytesseract \
    Pillow \
    pdf2image

# Install Playwright in user space to avoid conflicts with n8n
USER node
RUN npm install playwright@latest

# Install other Node.js packages in user space
RUN npm install \
    tesseract.js \
    jimp \
    pdf-poppler

# Switch back to root to set final permissions and cleanup
USER root

# DO NOT rebuild sharp globally - this is likely breaking task runners
# The original n8n image already has the correct sharp version
# Only rebuild if absolutely necessary and in a way that doesn't break n8n

# Alternative: Install sharp locally if needed
# USER node
# RUN npm install sharp
# USER root

# Set up proper directories and permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod 755 /home/node/.n8n

# Create n8n config
RUN echo '{}' > /home/node/.n8n/config && \
    chown node:node /home/node/.n8n/config && \
    chmod 600 /home/node/.n8n/config

# Verify installations without breaking existing setup
RUN node --version && npm --version

USER node

# Set environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/bin
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata/