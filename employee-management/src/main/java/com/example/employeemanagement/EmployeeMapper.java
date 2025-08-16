package com.example.employeemanagement;

import com.example.employeemanagement.dto.EmployeeDto;
import com.example.employeemanagement.model.Employee;
import org.springframework.stereotype.Component;

@Component
public class EmployeeMapper {

    public EmployeeDto mapToDto(Employee employee) {
        return new EmployeeDto(
                employee.getId(),
                employee.getFirstName(),
                employee.getLastName(),
                employee.getEmail(),
                employee.getPosition(),
                employee.getDepartment(),
                employee.getSalary()
        );
    }

    public Employee mapToEntity(EmployeeDto employeeDto) {
        return new Employee(
                employeeDto.getFirstName(),
                employeeDto.getLastName(),
                employeeDto.getEmail(),
                employeeDto.getPosition(),
                employeeDto.getDepartment(),
                employeeDto.getSalary()
        );
    }

    public void updateEntityFromDto(Employee employee, EmployeeDto employeeDto) {
        employee.setFirstName(employeeDto.getFirstName());
        employee.setLastName(employeeDto.getLastName());
        employee.setEmail(employeeDto.getEmail());
        employee.setPosition(employeeDto.getPosition());
        employee.setDepartment(employeeDto.getDepartment());
        employee.setSalary(employeeDto.getSalary());
    }
}

