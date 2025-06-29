#!/bin/bash
# Filename: setup_project.sh
# Description: A master script to generate the complete project structure for laundr.me,
# including root configuration, backend, and frontend applications.

# --- Function to Generate Project Root Files ---
generate_root_files() {
    echo "-----------------------------------------"
    echo "Generating project root files..."
    echo "-----------------------------------------"

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

1.  **Configure Environment**: Populate the root `.env` file with your credentials.
    Refer to `CONFIGURATION_VARS.md` for details.

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
API_BASE_URL=http://127.0.0.1:5000
EOF

    echo "Project root files generated successfully."
}

# --- Function to Generate Backend Application ---
generate_backend() {
    echo "-----------------------------------------"
    echo "Generating backend application..."
    echo "-----------------------------------------"

    echo "Creating backend directory structure..."
    mkdir -p backend/app/api/v1 backend/app/services backend/app/utils backend/migrations/versions

    echo "Generating all backend files..."

    # --- Filename: backend/Dockerfile ---
    cat << 'EOF' > backend/Dockerfile
FROM python:3.9-slim
WORKDIR /usr/src/app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]
EOF

    # --- Filename: backend/requirements.txt ---
    cat << 'EOF' > backend/requirements.txt
Flask==2.2.2
python-dotenv==0.21.0
psycopg2-binary==2.9.5
Flask-SQLAlchemy==3.0.2
Flask-Migrate==4.0.0
Flask-Bcrypt==1.0.1
PyJWT==2.6.0
requests==2.28.1
gunicorn==20.1.0
Flask-Cors==3.0.10
pydantic==1.10.2
EOF

    # --- Filename: backend/config.py ---
    cat << 'EOF' > backend/config.py
import os
from dotenv import load_dotenv

dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path=dotenv_path)

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ASTRA_API_KEY = os.getenv('ASTRA_API_KEY')

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_ECHO = False

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_ECHO = False

config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
}
EOF

    # --- Filename: backend/run.py ---
    cat << 'EOF' > backend/run.py
import os
from app import create_app

env_name = os.getenv('FLASK_ENV', 'development')
app = create_app(env_name)

if __name__ == '__main__':
    app.run()
EOF

    # --- Filename: backend/app/__init__.py ---
    cat << 'EOF' > backend/app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_migrate import Migrate
from flask_cors import CORS
from config import config_by_name

db = SQLAlchemy()
bcrypt = Bcrypt()

def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])
    
    db.init_app(app)
    bcrypt.init_app(app)
    Migrate(app, db)
    CORS(app)

    with app.app_context():
        from .api.v1 import auth, users, freelancers, payments, ratings
        app.register_blueprint(auth.bp, url_prefix='/api/v1/auth')
        app.register_blueprint(users.bp, url_prefix='/api/v1/users')
        app.register_blueprint(freelancers.bp, url_prefix='/api/v1/freelancers')
        app.register_blueprint(payments.bp, url_prefix='/api/v1/payments')
        app.register_blueprint(ratings.bp, url_prefix='/api/v1/ratings')
    
    return app
EOF

    # --- Filename: backend/app/models.py ---
    cat << 'EOF' > backend/app/models.py
import datetime
from sqlalchemy.dialects.postgresql import JSONB
from app import db, bcrypt

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    
    def __init__(self, username, email, password):
        self.username = username
        self.email = email
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)
EOF

    # --- Filename: backend/app/utils/decorators.py ---
    cat << 'EOF' > backend/app/utils/decorators.py
from functools import wraps
import jwt
from flask import request, jsonify, current_app
from app.models import User

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'message': 'Authorization header is missing or invalid!'}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, current_app.config['JWT_SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'message': 'User not found!'}), 401
            return f(current_user, *args, **kwargs)
        except Exception as e:
            return jsonify({'message': 'Token is invalid!', 'error': str(e)}), 401
    return decorated
EOF

    # --- Filename: backend/app/api/v1/auth.py ---
    cat << 'EOF' > backend/app/api/v1/auth.py
import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from app.models import User
from app import db

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not all(k in data for k in ('email', 'password', 'username')):
        return jsonify({'message': 'Missing required fields'}), 400
    if User.query.filter((User.email == data['email']) | (User.username == data['username'])).first():
        return jsonify({'message': 'User with that email or username already exists'}), 409
    
    new_user = User(username=data['username'], email=data['email'], password=data['password'])
    db.session.add(new_user)
    db.session.commit()
    return jsonify({'message': 'User registered successfully'}), 201

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data.get('email')).first()
    if user and user.check_password(data.get('password')):
        token = jwt.encode({
            'user_id': user.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, current_app.config['JWT_SECRET_KEY'], algorithm="HS256")
        return jsonify({
            'token': token, 
            'user': {'id': user.id, 'username': user.username, 'email': user.email}
        }), 200
    return jsonify({'message': 'Invalid credentials'}), 401
EOF

    # --- Create empty but valid blueprint files ---
    cat << 'EOF' > backend/app/api/v1/users.py
from flask import Blueprint
bp = Blueprint('users', __name__)
EOF

    cat << 'EOF' > backend/app/api/v1/freelancers.py
from flask import Blueprint
bp = Blueprint('freelancers', __name__)
EOF

    cat << 'EOF' > backend/app/api/v1/payments.py
from flask import Blueprint
bp = Blueprint('payments', __name__)
EOF

    cat << 'EOF' > backend/app/api/v1/ratings.py
from flask import Blueprint
bp = Blueprint('ratings', __name__)
EOF

    # --- Finalize backend setup ---
    chmod +x backend/run.py
    echo "Backend generation complete."
}

# --- Function to Generate Frontend Application ---
generate_frontend() {
    echo "-----------------------------------------"
    echo "Generating frontend application..."
    echo "-----------------------------------------"

    echo "Creating frontend directory structure..."
    mkdir -p frontend/src/api frontend/src/components/core frontend/src/state frontend/src/navigation frontend/src/screens/Auth frontend/src/screens/Home

    echo "Generating all frontend files..."

    # --- Filename: frontend/package.json ---
    cat << 'EOF' > frontend/package.json
{
  "name": "laundrme",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "start": "react-native start"
  },
  "dependencies": {
    "@react-navigation/bottom-tabs": "^6.5.20",
    "@react-navigation/native": "^6.1.17",
    "@react-navigation/stack": "^6.3.29",
    "axios": "^1.6.8",
    "react": "18.2.0",
    "react-native": "0.74.1",
    "react-native-dotenv": "^3.4.11",
    "react-native-gesture-handler": "^2.16.2",
    "react-native-safe-area-context": "^4.10.1",
    "react-native-screens": "^3.31.1",
    "zustand": "^4.5.2"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "@react-native/babel-preset": "0.74.83",
    "@react-native/eslint-config": "0.74.83",
    "@react-native/metro-config": "0.74.83",
    "@react-native/typescript-config": "0.74.83",
    "@types/react": "^18.2.6",
    "@types/react-test-renderer": "^18.0.0",
    "babel-jest": "^29.6.3",
    "babel-plugin-module-resolver": "^5.0.2",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.2.0",
    "typescript": "5.0.4"
  }
}
EOF

    # --- Filename: frontend/metro.config.js (ADDED) ---
    cat << 'EOF' > frontend/metro.config.js
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = {};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
EOF

    # --- Filename: frontend/babel.config.js ---
    cat << 'EOF' > frontend/babel.config.js
module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ["module:react-native-dotenv", { "moduleName": "@env", "path": ".env", "safe": true, "allowUndefined": false }],
    ['module-resolver', { 'root': ['./src'], 'alias': { '@': './src' } }]
  ],
};
EOF

    # --- Filename: frontend/tsconfig.json ---
    cat << 'EOF' > frontend/tsconfig.json
{ "extends": "@react-native/typescript-config/tsconfig.json" }
EOF

    # --- Filename: frontend/index.js ---
    cat << 'EOF' > frontend/index.js
import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
AppRegistry.registerComponent(appName, () => App);
EOF

    # --- Filename: frontend/app.json ---
    cat << 'EOF' > frontend/app.json
{ "name": "laundrme", "displayName": "laundr.me" }
EOF

    # --- Filename: frontend/App.tsx ---
    cat << 'EOF' > frontend/App.tsx
import React from 'react';
import { StatusBar, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import AppNavigator from '@/navigation/AppNavigator';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

const App = () => (
  <GestureHandlerRootView style={styles.container}>
    <NavigationContainer>
      <StatusBar barStyle="light-content" />
      <AppNavigator />
    </NavigationContainer>
  </GestureHandlerRootView>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
EOF

    # --- Filename: frontend/src/api/apiClient.ts ---
    cat << 'EOF' > frontend/src/api/apiClient.ts
import axios from 'axios';
import { API_BASE_URL } from '@env';
import { useAuthStore } from '@/state/authStore';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default apiClient;
EOF

    # --- Filename: frontend/src/state/authStore.ts ---
    cat << 'EOF' > frontend/src/state/authStore.ts
import { create } from 'zustand';

type User = { id: number; username: string; email: string; };

interface AuthState {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;
  setAuth: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  user: null,
  isAuthenticated: false,
  setAuth: (token, user) => set({ token, user, isAuthenticated: true }),
  logout: () => set({ token: null, user: null, isAuthenticated: false }),
}));
EOF

    # --- Filename: frontend/src/navigation/AppNavigator.tsx ---
    cat << 'EOF' > frontend/src/navigation/AppNavigator.tsx
import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { useAuthStore } from '@/state/authStore';
import MainTabNavigator from './MainTabNavigator';
import AuthNavigator from './AuthNavigator';

const RootStack = createStackNavigator();

const AppNavigator = () => {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);

  return (
    <RootStack.Navigator screenOptions={{ headerShown: false }}>
      {isAuthenticated ? (
        <RootStack.Screen name="MainApp" component={MainTabNavigator} />
      ) : (
        <RootStack.Screen name="Auth" component={AuthNavigator} />
      )}
    </RootStack.Navigator>
  );
};

export default AppNavigator;
EOF

    # --- Filename: frontend/src/navigation/AuthNavigator.tsx ---
    cat << 'EOF' > frontend/src/navigation/AuthNavigator.tsx
import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import LoginScreen from '@/screens/Auth/LoginScreen';
import RegisterScreen from '@/screens/Auth/RegisterScreen';

const Stack = createStackNavigator();

const AuthNavigator = () => (
  <Stack.Navigator>
    <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
    <Stack.Screen name="Register" component={RegisterScreen} options={{ title: 'Create Account' }}/>
  </Stack.Navigator>
);

export default AuthNavigator;
EOF

    # --- Filename: frontend/src/navigation/MainTabNavigator.tsx ---
    cat << 'EOF' > frontend/src/navigation/MainTabNavigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import HomeScreen from '@/screens/Home/HomeScreen';

const Tab = createBottomTabNavigator();

const MainTabNavigator = () => (
  <Tab.Navigator>
    <Tab.Screen name="Home" component={HomeScreen} />
    {/* Add other tab screens here */}
  </Tab.Navigator>
);

export default MainTabNavigator;
EOF

    # --- Filename: frontend/src/screens/Auth/LoginScreen.tsx ---
    cat << 'EOF' > frontend/src/screens/Auth/LoginScreen.tsx
import React, { useState } from 'react';
import { View, Text, TextInput, Button, Alert, StyleSheet, TouchableOpacity } from 'react-native';
import { useAuthStore } from '@/state/authStore';
import apiClient from '@/api/apiClient';

const LoginScreen = ({ navigation }: any) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const setAuth = useAuthStore(state => state.setAuth);

    const handleLogin = async () => {
        if (!email || !password) return Alert.alert('Error', 'Please enter email and password.');
        try {
            const response = await apiClient.post('/api/v1/auth/login', { email, password });
            setAuth(response.data.token, response.data.user);
        } catch (error: any) {
            Alert.alert('Login Failed', error.response?.data?.message || 'An error occurred.');
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>laundr.me</Text>
            <TextInput style={styles.input} placeholder="Email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" />
            <TextInput style={styles.input} placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry />
            <Button title="Log In" onPress={handleLogin} color="#FF0088" />
            <TouchableOpacity onPress={() => navigation.navigate('Register')}>
                 <Text style={styles.link}>Don't have an account? Sign Up</Text>
            </TouchableOpacity>
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 20, backgroundColor: '#000' },
    title: { fontSize: 48, fontWeight: '600', color: '#fff', textAlign: 'center', marginBottom: 40 },
    input: { backgroundColor: '#333', color: '#fff', padding: 15, borderRadius: 5, marginBottom: 15 },
    link: { color: '#FF0088', textAlign: 'center', marginTop: 20 }
});

export default LoginScreen;
EOF

    # --- Filename: frontend/src/screens/Auth/RegisterScreen.tsx ---
    cat << 'EOF' > frontend/src/screens/Auth/RegisterScreen.tsx
import React, { useState } from 'react';
import { View, TextInput, Button, Alert, StyleSheet } from 'react-native';
import apiClient from '@/api/apiClient';

const RegisterScreen = ({ navigation }: any) => {
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleRegister = async () => {
        if (!username || !email || !password) return Alert.alert('Error', 'Please fill all fields.');
        try {
            await apiClient.post('/api/v1/auth/register', { username, email, password });
            Alert.alert('Success', 'You have registered successfully!', [{ text: 'OK', onPress: () => navigation.navigate('Login') }]);
        } catch (error: any) {
            Alert.alert('Registration Failed', error.response?.data?.message || 'An error occurred.');
        }
    };

    return (
        <View style={styles.container}>
            <TextInput style={styles.input} placeholder="Username" value={username} onChangeText={setUsername} />
            <TextInput style={styles.input} placeholder="Email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" />
            <TextInput style={styles.input} placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry />
            <Button title="Register" onPress={handleRegister} color="#FF0088" />
        </View>
    );
};
const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 20, backgroundColor: '#000' },
    input: { backgroundColor: '#333', color: '#fff', padding: 15, borderRadius: 5, marginBottom: 15 },
});
export default RegisterScreen;
EOF

    # --- Filename: frontend/src/screens/Home/HomeScreen.tsx ---
    cat << 'EOF' > frontend/src/screens/Home/HomeScreen.tsx
import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { useAuthStore } from '@/state/authStore';

const HomeScreen = () => {
    const { user, logout } = useAuthStore();

    return (
        <View style={styles.container}>
            <Text style={styles.welcome}>Welcome, {user?.username}!</Text>
            <Button title="Logout" onPress={logout} color="#FF0088" />
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#000' },
    welcome: { color: '#fff', fontSize: 24, marginBottom: 20 }
});

export default HomeScreen;
EOF

    echo "Frontend generation complete."
}

# --- Main Execution ---
main() {
    echo "Starting full project setup for laundr.me..."
    
    generate_root_files
    generate_backend
    generate_frontend

    echo "-----------------------------------------"
    echo "✅ Project setup complete!"
    echo "IMPORTANT: Please edit the '.env' file with your actual credentials."
    echo "You can now follow the instructions in README.md to run the project."
    echo "-----------------------------------------"
}

# --- Run Main Function ---
main