class EmployeeManager {
    constructor() {
        this.authToken = localStorage.getItem('authToken');
        this.currentUser = JSON.parse(localStorage.getItem('currentUser'));
        this.employees = [];
        this.init();
    }

    init() {
        this.setupEventListeners();
        // Load initial view based on login state
        if (this.authToken) {
            this.loadEmployees();
            this.updateUIAfterLogin();
        } else {
            this.loadEmployeesPublic();
        }
    }

    setupEventListeners() {
        // Login modal
        document.getElementById('loginBtn').addEventListener('click', () => this.showLoginModal());
        document.getElementById('closeLoginBtn').addEventListener('click', () => this.hideLoginModal());
        document.getElementById('loginForm').addEventListener('submit', (e) => this.handleLogin(e));
        
        // Admin forms
        document.getElementById('createEmployeeForm').addEventListener('submit', (e) => this.handleCreateEmployee(e));
        document.getElementById('updateEmployeeForm').addEventListener('submit', (e) => this.handleUpdateEmployee(e));
        document.getElementById('deleteEmployeeForm').addEventListener('submit', (e) => this.handleDeleteEmployee(e));
        
        // Logout
        document.getElementById('logoutBtn').addEventListener('click', () => this.logout());

        // Event delegation for employee actions on the list
        document.getElementById('employeeList').addEventListener('click', (e) => {
            const button = e.target.closest('button[data-action]');
            if (!button) return;

            const action = button.dataset.action;
            const id = parseInt(button.dataset.id, 10);

            if (action === 'edit') {
                this.editEmployee(id);
            } else if (action === 'delete') {
                this.handleCardDelete(id);
            }
        });
        
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
            const response = await fetch('/api/auth/signin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password })
            });

            if (response.ok) {
                const data = await response.json();
                this.authToken = data.accessToken;
                this.currentUser = { username };
                
                // Persist login state
                localStorage.setItem('authToken', this.authToken);
                localStorage.setItem('currentUser', JSON.stringify(this.currentUser));

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
        document.getElementById('adminSections').style.display = 'block';
    }

    // Load employees without authentication (public view)
    async loadEmployeesPublic() {
        const employeeList = document.getElementById('employeeList');
        employeeList.innerHTML = '<div class="loading">Loading employees...</div>';
        try {
            const response = await fetch('/api/employees');
            if (response.ok) {
                this.employees = await response.json();
                this.displayEmployeesPublic();
                this.updateStats();
            } else {
                this.showStatus('Failed to load employees!', 'error');
                employeeList.innerHTML = '<div class="empty-state">Could not load employees.</div>';
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
            employeeList.innerHTML = '<div class="empty-state">Could not load employees.</div>';
        }
    }

    // Load employees with authentication (admin view)
    async loadEmployees() {
        if (!this.authToken) return this.loadEmployeesPublic();

        const employeeList = document.getElementById('employeeList');
        employeeList.innerHTML = '<div class="loading">Loading employees...</div>';
        try {
            const response = await fetch('/api/employees', {
                headers: { 'Authorization': 'Bearer ' + this.authToken }
            });

            if (response.ok) {
                this.employees = await response.json();
                this.displayEmployees();
                this.updateStats();
            } else {
                // Handle expired token or other auth issues
                if (response.status === 401 || response.status === 403) {
                    this.showStatus('Your session has expired. Please log in again.', 'error');
                    this.logout();
                } else {
                    const errorText = await response.text();
                    this.showStatus(`Failed to load employees: ${errorText}`, 'error');
                    employeeList.innerHTML = '<div class="empty-state">Could not load employees.</div>';
                }
            }
        } catch (error) {
            this.showStatus('Error: ' + error.message, 'error');
            employeeList.innerHTML = '<div class="empty-state">Could not load employees.</div>';
        }
    }

    displayEmployeesPublic() {
        const container = document.getElementById('employeeList');
        container.innerHTML = ''; // Clear the container first

        if (this.employees.length === 0) {
            container.innerHTML = `<div class="empty-state"><i>👥</i><h3>No Employees Found</h3><p>No employees have been added yet.</p></div>`;
            return;
        }

        const fragment = document.createDocumentFragment();
        this.employees.forEach(emp => {
            const cardElement = this.createEmployeeCard(emp, false);
            fragment.appendChild(cardElement);
        });
        container.appendChild(fragment);
    }

    displayEmployees() {
        const container = document.getElementById('employeeList');
        container.innerHTML = ''; // Clear the container first

        if (this.employees.length === 0) {
            container.innerHTML = `<div class="empty-state"><i>👥</i><h3>No Employees Found</h3><p>Start by adding your first employee using the form above.</p></div>`;
            return;
        }

        const fragment = document.createDocumentFragment();
        this.employees.forEach(emp => {
            const cardElement = this.createEmployeeCard(emp, true);
            fragment.appendChild(cardElement);
        });
        container.appendChild(fragment);
    }

    createEmployeeCard(emp, isAdmin) {
        const card = document.createElement('div');
        card.className = 'employee-card slide-up';

        const header = document.createElement('div');
        header.className = 'employee-header';

        const nameAndPositionDiv = document.createElement('div');
        const nameDiv = document.createElement('div');
        nameDiv.className = 'employee-name';
        nameDiv.textContent = `${emp.firstName} ${emp.lastName}`;
        const positionDiv = document.createElement('div');
        positionDiv.style.cssText = 'color: #666; font-size: 0.9rem;';
        positionDiv.textContent = emp.position;
        nameAndPositionDiv.append(nameDiv, positionDiv);

        const idDiv = document.createElement('div');
        idDiv.className = 'employee-id';
        idDiv.textContent = `#${emp.id}`;

        header.append(nameAndPositionDiv, idDiv);

        const details = document.createElement('div');
        details.className = 'employee-details';

        const createDetail = (label, value) => {
            const detailDiv = document.createElement('div');
            detailDiv.className = 'employee-detail';
            const labelSpan = document.createElement('span');
            labelSpan.className = 'detail-label';
            labelSpan.textContent = label;
            const valueSpan = document.createElement('span');
            valueSpan.className = 'detail-value';
            valueSpan.textContent = value;
            detailDiv.append(labelSpan, valueSpan);
            return detailDiv;
        };

        details.appendChild(createDetail('Email:', emp.email));
        details.appendChild(createDetail('Department:', emp.department || 'N/A'));
        details.appendChild(createDetail('Salary:', emp.salary ? '$' + emp.salary.toLocaleString() : 'N/A'));

        card.append(header, details);

        if (isAdmin) {
            const actions = document.createElement('div');
            actions.className = 'employee-actions';
            const createActionButton = (text, action, id, btnClass) => {
                const button = document.createElement('button');
                button.className = `btn ${btnClass} btn-sm`;
                // Set data attributes for event delegation
                button.dataset.action = action;
                button.dataset.id = id;
                button.innerHTML = text; // Use innerHTML to render emoji correctly
                return button;
            };

            const editButton = createActionButton('✏️ Edit', 'edit', emp.id, 'btn-secondary');
            const deleteButton = createActionButton('🗑️ Delete', 'delete', emp.id, 'btn-danger');

            actions.append(editButton, deleteButton);
            card.appendChild(actions);
        }

        return card;
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
        if (!this.authToken) return this.showStatus('Please login first!', 'error');

        const formData = new FormData(e.target);
        const employee = Object.fromEntries(formData.entries());
        employee.salary = employee.salary ? parseInt(employee.salary) : null;

        try {
            const response = await fetch('/api/employees', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.authToken },
                body: JSON.stringify(employee)
            });

            if (response.ok) {
                const newEmployee = await response.json();
                this.showStatus(`Employee ${newEmployee.firstName} created successfully!`, 'success');
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

        document.getElementById('updateId').value = employee.id;
        document.getElementById('updateFirstName').value = employee.firstName;
        document.getElementById('updateLastName').value = employee.lastName;
        document.getElementById('updateEmail').value = employee.email;
        document.getElementById('updatePosition').value = employee.position;
        document.getElementById('updateDepartment').value = employee.department || '';
        document.getElementById('updateSalary').value = employee.salary || '';

        document.getElementById('updateEmployeeForm').scrollIntoView({ behavior: 'smooth' });
    }

    async handleUpdateEmployee(e) {
        e.preventDefault();
        if (!this.authToken) return this.showStatus('Please login first!', 'error');

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
            const response = await fetch(`/api/employees/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.authToken },
                body: JSON.stringify(employee)
            });

            if (response.ok) {
                this.showStatus(`Employee updated successfully!`, 'success');
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

    handleCardDelete(id) {
        const employee = this.employees.find(emp => emp.id === id);
        if (!employee) return;

        if (confirm(`Are you sure you want to delete ${employee.firstName} ${employee.lastName}?`)) {
            this.deleteEmployee(id);
        }
    }

    async deleteEmployee(id) {
        if (!this.authToken) return this.showStatus('Please login first!', 'error');

        const employee = this.employees.find(emp => emp.id === id);
        if (!employee) {
            this.showStatus(`Error: Employee with ID ${id} not found in the current list.`, 'error');
            return;
        }

        try {
            const response = await fetch(`/api/employees/${id}`, {
                method: 'DELETE',
                headers: { 'Authorization': 'Bearer ' + this.authToken }
            });

            if (response.ok) {
                this.showStatus(`Employee deleted successfully!`, 'success');
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
        const idInput = document.getElementById('deleteId');
        const id = idInput.value;
        const employee = this.employees.find(emp => emp.id === parseInt(id, 10));

        if (id && !isNaN(id) && employee) {
            // For the form, we can also add a confirmation for safety
            if (!confirm(`This will permanently delete ${employee.firstName} ${employee.lastName} (ID: ${id}). Are you sure?`)) return;
            await this.deleteEmployee(parseInt(id, 10));
            e.target.reset();
        } else {
            this.showStatus('Please enter a valid Employee ID to delete.', 'error');
        }
    }

    logout() {
        this.authToken = '';
        this.currentUser = null;
        localStorage.removeItem('authToken');
        localStorage.removeItem('currentUser');
        
        document.getElementById('loginBtn').style.display = 'block';
        document.getElementById('userInfo').style.display = 'none';
        document.getElementById('logoutBtn').style.display = 'none';
        document.getElementById('adminSections').style.display = 'none';
        
        this.loadEmployeesPublic();
        this.showStatus('Logged out successfully!', 'info');
    }

    showStatus(message, type = 'info') {
        const statusDiv = document.createElement('div');
        statusDiv.className = `status ${type}`;
        statusDiv.textContent = message;
        
        document.querySelectorAll('.status').forEach(el => el.remove());
        
        const mainContainer = document.querySelector('.main-container');
        mainContainer.insertBefore(statusDiv, mainContainer.firstChild);
        
        setTimeout(() => { statusDiv.remove(); }, 5000);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new EmployeeManager();
});