# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during installations
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and Chrome
RUN apt update && \
    apt install -y wget gnupg sudo xfce4 desktop-base xfce4-terminal xscreensaver dbus-x11 && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' && \
    apt update && \
    apt install -y google-chrome-stable && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Add the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the script executable
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command to start the container
CMD ["bash"]
