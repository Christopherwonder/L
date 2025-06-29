#!/bin/bash
# Filename: create_root_files.sh

echo "Generating project root files..."

# --- Filename: .gitignore ---
cat << 'EOF' > .gitignore
# Node / React Native
node_modules/
npm-debug.log
yarn-error.log
.DS_Store
*.js.map
*.podspec

# iOS & Android
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
DerivedData
*.hmap
*.ipa
*.app
Pods/
.gradle
app/build/
*.iml
.idea/
local.properties
*.keystore

# Python
__pycache__/
*.py[cod]
.Python
dist/
*.egg-info/
.installed.cfg
*.egg

# Environment
.env
.env.*

# IDE / OS
.vscode/
*.swp
*~
.DS_Store
EOF

# --- Filename: README.md ---
cat << 'EOF' > README.md
# laundr.me

This is the main repository for the **laundr.me** project, a mobile-first peer-to-peer (P2P) financial transfer platform.

## Getting Started

### Prerequisites

-   Docker and Docker Compose
-   A Codespaces environment (or a local setup with the above tools)
-   Node.js and npm/yarn for frontend development
-   An iOS or Android development environment (Xcode/Android Studio)

### Setup

1.  **Configure Environment**: Populate the root `.env` file with your credentials. Refer to `CONFIGURATION_VARS.md` for details.

2.  **Build and Run Backend**:
    ```bash
    docker-compose up --build -d
    ```

3.  **Run the Frontend**:
    -   Navigate to the `frontend` directory: `cd frontend`
    -   Install dependencies: `npm install`
    -   Start the Metro bundler: `npm start`
    -   In a new terminal, run on your simulator: `npm run ios` or `npm run android`
EOF

# --- Filename: docker-compose.yml ---
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    container_name: laundr_me_backend
    ports: ["5000:5000"]
    volumes: ["./backend:/usr/src/app"]
    env_file: [".env"]
    depends_on: [db]
    command: gunicorn --bind 0.0.0.0:5000 --workers 2 --threads 4 --reload run:app
  db:
    image: postgres:13-alpine
    container_name: laundr_me_db
    volumes: ["postgres_data:/var/lib/postgresql/data/"]
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
volumes:
  postgres_data:
EOF

# --- Filename: .env (template to be filled by user) ---
cat << 'EOF' > .env
# Backend & Database Configuration
FLASK_APP=run.py
FLASK_ENV=development
SECRET_KEY=
DATABASE_URL=
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
JWT_SECRET_KEY=
# Astra
ASTRA_API_KEY=
ASTRA_API_SECRET=
ASTRA_WEBHOOK_SECRET=
# Frontend
API_BASE_URL=
EOF

echo "Project root files generated successfully."
echo "IMPORTANT: Please edit the '.env' file with your actual credentials."
EOF

# --- Make script executable ---
chmod +x create_root_files.sh
echo "create_root_files.sh has been created."

