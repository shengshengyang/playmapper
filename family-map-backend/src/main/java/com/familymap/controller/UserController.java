package com.familymap.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "User", description = "使用者 API")
public class UserController {

    @GetMapping("/me")
    @Operation(summary = "獲取當前使用者資訊")
    public ResponseEntity<Map<String, Object>> getCurrentUser() {
        // TODO: 實作使用者認證後返回真實資料
        return ResponseEntity.ok(Map.of(
            "id", 1,
            "username", "demo",
            "email", "demo@example.com",
            "role", "user"
        ));
    }

    @PostMapping("/register")
    @Operation(summary = "註冊新使用者")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String email = request.get("email");
        String password = request.get("password");

        // TODO: 實作註冊邏輯

        return ResponseEntity.ok(Map.of(
            "message", "註冊成功",
            "username", username
        ));
    }

    @PostMapping("/login")
    @Operation(summary = "使用者登入")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        // 測試模式：admin/admin123 直接返回成功
        if ("admin".equals(username) && "admin123".equals(password)) {
            return ResponseEntity.ok(Map.of(
                "message", "登入成功",
                "token", "test-admin-token",
                "user", Map.of(
                    "id", 1,
                    "username", "admin",
                    "role", "admin"
                )
            ));
        }

        // TODO: 實作真實登入邏輯和 JWT 生成
        return ResponseEntity.status(401).body(Map.of(
            "message", "帳號或密碼錯誤"
        ));
    }

    @PostMapping("/logout")
    @Operation(summary = "使用者登出")
    public ResponseEntity<Map<String, String>> logout() {
        // TODO: 實作登出邏輯（如需要）

        return ResponseEntity.ok(Map.of("message", "登出成功"));
    }
}
