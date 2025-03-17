package com.bank.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SHA256Util {

    // Method to hash a string using SHA-256
    public static String hash(String input) {
        try {
            // Create a MessageDigest instance for SHA-256
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            // Perform the hashing
            byte[] hashBytes = digest.digest(input.getBytes());
            // Convert the byte array to a hexadecimal string
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not found", e);
        }
    }

    // Method to verify a password against a hashed value
    public static boolean verify(String input, String hashedInput) {
        return hash(input).equals(hashedInput);
    }
}