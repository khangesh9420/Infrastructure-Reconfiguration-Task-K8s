FROM node:18

# Set working directory
WORKDIR /app

COPY package*.json ./


RUN npm ci --omit=dev

# Copy app source code
COPY . .

# Expose the service port
EXPOSE 5001

# Run the service
CMD ["node", "index.js"]
