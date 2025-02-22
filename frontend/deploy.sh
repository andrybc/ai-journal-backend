#!/bin/bash
# Navigate to your repository directory
cd /home/deploy/journal-organizer/frontend || exit

# Get the current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch is: $CURRENT_BRANCH"

# Optionally, you can check if it's the expected branch
if [ "$CURRENT_BRANCH" != "potential_setup" ]; then
  echo "Warning: You are not on the potential_setup branch."
  # Optionally, exit or prompt for confirmation
  # exit 1
fi

# Continue with the deploy process:
git pull origin "$CURRENT_BRANCH"
npm install
npm run build

sudo mkdir -p /var/www/journal-app
sudo cp -r dist/* /var/www/journal-app/
sudo systemctl reload nginx

echo "Deployment complete!"
