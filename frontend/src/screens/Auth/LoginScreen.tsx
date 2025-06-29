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
