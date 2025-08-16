package com.example.employeemanagement.config;

import com.example.employeemanagement.model.Role;
import com.example.employeemanagement.model.RoleName;
import com.example.employeemanagement.model.User;
import com.example.employeemanagement.repository.RoleRepository;
import com.example.employeemanagement.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final String adminUsername;
    private final String adminPassword;

    public DataInitializer(RoleRepository roleRepository,
                           UserRepository userRepository,
                           PasswordEncoder passwordEncoder,
                           @Value("${app.admin.username:admin}") String adminUsername,
                           @Value("${app.admin.password:admin123}") String adminPassword) {
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.adminUsername = adminUsername;
        this.adminPassword = adminPassword;
    }

    @Override
    @Transactional
    public void run(String... args) {
        logger.info("Initializing data...");

        // 1. Initialize all roles from the Enum
        Arrays.stream(RoleName.values()).forEach(roleName -> {
            if (roleRepository.findByName(roleName).isEmpty()) {
                roleRepository.save(new Role(roleName));
                logger.info("Created {} role", roleName);
            }
        });

        // 2. Create or update the default admin user to ensure its state is correct
        User adminUser = userRepository.findByUsername(adminUsername)
                .orElseGet(() -> {
                    logger.info("Creating default admin user with username '{}'", adminUsername);
                    return new User(
                            "Admin User",
                            adminUsername,
                            adminUsername + "@example.com",
                            passwordEncoder.encode(adminPassword)
                    );
                });

        Role adminRole = roleRepository.findByName(RoleName.ROLE_ADMIN)
                .orElseThrow(() -> new RuntimeException("Fatal: ROLE_ADMIN not found. Initialization failed."));

        if (!passwordEncoder.matches(adminPassword, adminUser.getPassword())) {
            logger.warn("Admin user password does not match configuration. Updating password...");
            adminUser.setPassword(passwordEncoder.encode(adminPassword));
        }

        if (!adminUser.hasRole(RoleName.ROLE_ADMIN)) {
            logger.warn("Admin user '{}' was missing ROLE_ADMIN. Correcting...", adminUsername);
            Set<Role> roles = new HashSet<>(adminUser.getRoles());
            roles.add(adminRole);
            adminUser.setRoles(roles);
        }

        userRepository.save(adminUser);
        logger.info("Data initialization complete.");
    }
}