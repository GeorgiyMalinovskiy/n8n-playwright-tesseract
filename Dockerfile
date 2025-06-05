FROM docker.n8n.io/n8nio/n8n:latest

USER node

# Install Node.js packages globally
RUN npm install -g \
    playwright@latest \
    tesseract.js \
    jimp

# Install Playwright browsers (with --yes to avoid prompts)
RUN npx playwright install --yes chromium firefox

# Set environment variables
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV NODE_ENV=production

# Verify installations
RUN npm list -g playwright tesseract.js jimp || true