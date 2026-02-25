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

        // TODO: 實作登入邏輯和 JWT 生成

        return ResponseEntity.ok(Map.of(
            "message", "登入成功",
            "token", "jwt-token-placeholder",
            "username", username
        ));
    }

    @PostMapping("/logout")
    @Operation(summary = "使用者登出")
    public ResponseEntity<Map<String, String>> logout() {
        // TODO: 實作登出邏輯（如需要）

        return ResponseEntity.ok(Map.of("message", "登出成功"));
    }
}
