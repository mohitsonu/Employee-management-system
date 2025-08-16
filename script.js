// Employee Management System JavaScript

class EmployeeManager {
    constructor() {
        this.authToken = '';
        this.employees = [];
        this.currentUser = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadEmployeesPublic(); // Load employees on homepage without login
    }

    setupEventListeners() {
        // Login modal
        document.getElementById('loginBtn').addEventListener('click', () => this.showLoginModal());
        document.getElementById('closeLoginBtn').addEventListener('click', () => this.hideLoginModal());
        document.getElementById('loginForm').addEventListener('submit', (e) => this.handleLogin(e));
        
        // Create employee form
        document.getElementById('createEmployeeForm').addEventListener('submit', (e) => this.handleCreateEmployee(e));
        
        // Update employee form
        document.getElementById('updateEmployeeForm').addEventListener('submit', (e) => this.handleUpdateEmployee(e));
        
        // Delete employee
        document.getElementById('deleteEmployeeForm').addEventListener('submit', (e) => this.handleDeleteEmployee(e));
        
        // Close modal when clicking outside
        document.getElementById('loginModal').addEventListener('click', (e) => {
            if (e.target.id === 'loginModal') {
                this.hideLoginModal();
            }
        });
    }

    showLoginModal() {
        document.getElementById('loginModal').classList.add('show');
    }

    hideLoginModal() {
        document.getElementById('loginModal').classList.remove('show');
    }

    async handleLogin(e) {
        e.preventDefault();
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        try {
            const response = await fetch('http://localhost:8082/api/auth/signin', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, password })
            });

            if (response.ok) {
                const data = await response.json();
                this.authToken = data.accessToken;
                this.currentUser = { username };
                this.hideLoginModal();
                this.updateUIAfterLogin();
                this.loadEmployees(); // Reload with admin access
                this.showStatus('Login successful!', 'success');
            } else {
                this.showStatus('Login failed! Please check your credentials.', 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    updateUIAfterLogin() {
        document.getElementById('loginBtn').style.display = 'none';
        document.getElementById('userInfo').style.display = 'flex';
        document.getElementById('userName').textContent = this.currentUser.username;
        document.getElementById('logoutBtn').style.display = 'block';
        
        // Show admin sections
        document.getElementById('adminSections').style.display = 'block';
    }

    // Load employees without authentication (public view)
    async loadEmployeesPublic() {
        try {
            const response = await fetch('http://localhost:8082/api/employees');
            
            if (response.ok) {
                this.employees = await response.json();
                this.displayEmployeesPublic();
                this.updateStats();
            } else {
                this.showStatus('Failed to load employees!', 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    // Load employees with authentication (admin view)
    async loadEmployees() {
        if (!this.authToken) {
            this.showStatus('Please login first!', 'error');
            return;
        }

        try {
            const response = await fetch('http://localhost:8082/api/employees', {
                headers: {
                    'Authorization': 'Bearer ' + this.authToken
                }
            });

            if (response.ok) {
                this.employees = await response.json();
                this.displayEmployees();
                this.updateStats();
            } else {
                this.showStatus('Failed to load employees!', 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    displayEmployeesPublic() {
        const container = document.getElementById('employeeList');
        
        if (this.employees.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i>👥</i>
                    <h3>No Employees Found</h3>
                    <p>No employees have been added yet.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = this.employees.map(emp => `
            <div class="employee-card slide-up">
                <div class="employee-header">
                    <div>
                        <div class="employee-name">${emp.firstName} ${emp.lastName}</div>
                        <div style="color: #666; font-size: 0.9rem;">${emp.position}</div>
                    </div>
                    <div class="employee-id">#${emp.id}</div>
                </div>
                <div class="employee-details">
                    <div class="employee-detail">
                        <span class="detail-label">Email:</span>
                        <span class="detail-value">${emp.email}</span>
                    </div>
                    <div class="employee-detail">
                        <span class="detail-label">Department:</span>
                        <span class="detail-value">${emp.department || 'Not specified'}</span>
                    </div>
                    <div class="employee-detail">
                        <span class="detail-label">Salary:</span>
                        <span class="detail-value">${emp.salary ? '$' + emp.salary.toLocaleString() : 'Not specified'}</span>
                    </div>
                </div>
            </div>
        `).join('');
    }

    displayEmployees() {
        const container = document.getElementById('employeeList');
        
        if (this.employees.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i>👥</i>
                    <h3>No Employees Found</h3>
                    <p>Start by adding your first employee using the form above.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = this.employees.map(emp => `
            <div class="employee-card slide-up">
                <div class="employee-header">
                    <div>
                        <div class="employee-name">${emp.firstName} ${emp.lastName}</div>
                        <div style="color: #666; font-size: 0.9rem;">${emp.position}</div>
                    </div>
                    <div class="employee-id">#${emp.id}</div>
                </div>
                <div class="employee-details">
                    <div class="employee-detail">
                        <span class="detail-label">Email:</span>
                        <span class="detail-value">${emp.email}</span>
                    </div>
                    <div class="employee-detail">
                        <span class="detail-label">Department:</span>
                        <span class="detail-value">${emp.department || 'Not specified'}</span>
                    </div>
                    <div class="employee-detail">
                        <span class="detail-label">Salary:</span>
                        <span class="detail-value">${emp.salary ? '$' + emp.salary.toLocaleString() : 'Not specified'}</span>
                    </div>
                </div>
                <div class="employee-actions">
                    <button class="btn btn-secondary btn-sm" onclick="employeeManager.editEmployee(${emp.id})">
                        ✏️ Edit
                    </button>
                    <button class="btn btn-danger btn-sm" onclick="employeeManager.deleteEmployee(${emp.id})">
                        🗑️ Delete
                    </button>
                </div>
            </div>
        `).join('');
    }

    updateStats() {
        const totalEmployees = this.employees.length;
        const totalSalary = this.employees.reduce((sum, emp) => sum + (emp.salary || 0), 0);
        const avgSalary = totalEmployees > 0 ? Math.round(totalSalary / totalEmployees) : 0;

        document.getElementById('totalEmployees').textContent = totalEmployees;
        document.getElementById('totalSalary').textContent = '$' + totalSalary.toLocaleString();
        document.getElementById('avgSalary').textContent = '$' + avgSalary.toLocaleString();
    }

    async handleCreateEmployee(e) {
        e.preventDefault();
        if (!this.authToken) {
            this.showStatus('Please login first!', 'error');
            return;
        }

        const formData = new FormData(e.target);
        const employee = {
            firstName: formData.get('firstName'),
            lastName: formData.get('lastName'),
            email: formData.get('email'),
            position: formData.get('position'),
            department: formData.get('department') || null,
            salary: formData.get('salary') ? parseInt(formData.get('salary')) : null
        };

        try {
            const response = await fetch('http://localhost:8082/api/employees', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + this.authToken
                },
                body: JSON.stringify(employee)
            });

            if (response.ok) {
                const newEmployee = await response.json();
                this.showStatus(`Employee ${newEmployee.firstName} ${newEmployee.lastName} created successfully!`, 'success');
                e.target.reset();
                this.loadEmployees();
            } else {
                const errorData = await response.text();
                this.showStatus('Failed to create employee: ' + errorData, 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    editEmployee(id) {
        const employee = this.employees.find(emp => emp.id === id);
        if (!employee) return;

        // Populate update form
        document.getElementById('updateId').value = employee.id;
        document.getElementById('updateFirstName').value = employee.firstName;
        document.getElementById('updateLastName').value = employee.lastName;
        document.getElementById('updateEmail').value = employee.email;
        document.getElementById('updatePosition').value = employee.position;
        document.getElementById('updateDepartment').value = employee.department || '';
        document.getElementById('updateSalary').value = employee.salary || '';

        // Scroll to update form
        document.getElementById('updateEmployeeForm').scrollIntoView({ behavior: 'smooth' });
    }

    async handleUpdateEmployee(e) {
        e.preventDefault();
        if (!this.authToken) {
            this.showStatus('Please login first!', 'error');
            return;
        }

        const formData = new FormData(e.target);
        const id = formData.get('updateId');
        const employee = {
            firstName: formData.get('updateFirstName'),
            lastName: formData.get('updateLastName'),
            email: formData.get('updateEmail'),
            position: formData.get('updatePosition'),
            department: formData.get('updateDepartment') || null,
            salary: formData.get('updateSalary') ? parseInt(formData.get('updateSalary')) : null
        };

        try {
            const response = await fetch(`http://localhost:8082/api/employees/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + this.authToken
                },
                body: JSON.stringify(employee)
            });

            if (response.ok) {
                this.showStatus(`Employee ${employee.firstName} ${employee.lastName} updated successfully!`, 'success');
                e.target.reset();
                this.loadEmployees();
            } else {
                const errorData = await response.text();
                this.showStatus('Failed to update employee: ' + errorData, 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    async deleteEmployee(id) {
        if (!this.authToken) {
            this.showStatus('Please login first!', 'error');
            return;
        }

        const employee = this.employees.find(emp => emp.id === id);
        if (!employee) return;

        if (!confirm(`Are you sure you want to delete ${employee.firstName} ${employee.lastName}?`)) {
            return;
        }

        try {
            const response = await fetch(`http://localhost:8082/api/employees/${id}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': 'Bearer ' + this.authToken
                }
            });

            if (response.ok) {
                this.showStatus(`Employee ${employee.firstName} ${employee.lastName} deleted successfully!`, 'success');
                this.loadEmployees();
            } else {
                this.showStatus('Failed to delete employee!', 'error');
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
        }
    }

    async handleDeleteEmployee(e) {
        e.preventDefault();
        const id = document.getElementById('deleteId').value;
        if (id) {
            await this.deleteEmployee(parseInt(id));
            e.target.reset();
        }
    }

    logout() {
        this.authToken = '';
        this.currentUser = null;
        
        // Reset UI
        document.getElementById('loginBtn').style.display = 'block';
        document.getElementById('userInfo').style.display = 'none';
        document.getElementById('logoutBtn').style.display = 'none';
        
        // Hide admin sections
        document.getElementById('adminSections').style.display = 'none';
        
        // Reload employees in public view
        this.loadEmployeesPublic();
        
        this.showStatus('Logged out successfully!', 'info');
    }

    showStatus(message, type = 'info') {
        const statusDiv = document.createElement('div');
        statusDiv.className = `status ${type}`;
        statusDiv.textContent = message;
        
        // Remove existing status messages
        document.querySelectorAll('.status').forEach(el => el.remove());
        
        // Add new status message at the top
        const mainContainer = document.querySelector('.main-container');
        mainContainer.insertBefore(statusDiv, mainContainer.firstChild);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (statusDiv.parentNode) {
                statusDiv.remove();
            }
        }, 5000);
    }
}

// Initialize the application
let employeeManager;

document.addEventListener('DOMContentLoaded', () => {
    employeeManager = new EmployeeManager();
    
    // Setup logout button
    document.getElementById('logoutBtn').addEventListener('click', () => {
        employeeManager.logout();
    });
}); 