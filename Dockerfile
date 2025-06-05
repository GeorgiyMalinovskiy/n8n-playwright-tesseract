FROM docker.n8n.io/n8nio/n8n:latest

USER node

# Create directory structure for npm packages
RUN mkdir -p /home/node/.npm-global/lib && \
    mkdir -p /home/node/.npm-global/bin && \
    npm config set prefix '/home/node/.npm-global'

# Add npm global bin to PATH
ENV PATH=/home/node/.npm-global/bin:$PATH
ENV NODE_PATH=/home/node/.npm-global/lib/node_modules

# Install Node.js packages in user's directory
RUN npm install --prefix /home/node/.npm-global \
    playwright@latest \
    tesseract.js \
    jimp

# Install Playwright browsers (with --yes to avoid prompts)
RUN export PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright && \
    /home/node/.npm-global/bin/playwright install --yes chromium firefox

# Set environment variables
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV NODE_ENV=production

# Verify installations
RUN npm list --prefix /home/node/.npm-global playwright tesseract.js jimp || true