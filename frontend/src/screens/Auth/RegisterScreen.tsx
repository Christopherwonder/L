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
