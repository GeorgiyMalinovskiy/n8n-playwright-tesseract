FROM docker.n8n.io/n8nio/n8n:latest

USER node

# Create directory for global packages in user's home
RUN mkdir -p /home/node/.npm-global && \
    npm config set prefix '/home/node/.npm-global'

# Add npm global bin to PATH
ENV PATH=/home/node/.npm-global/bin:$PATH

# Install Node.js packages in user's directory
RUN npm install --prefix /home/node/.npm-global \
    playwright@latest \
    tesseract.js \
    jimp

# Install Playwright browsers (with --yes to avoid prompts)
RUN npx playwright install --yes chromium firefox

# Set environment variables
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV NODE_ENV=production

# Verify installations
RUN npm list --prefix /home/node/.npm-global playwright tesseract.js jimp || true