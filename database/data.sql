INSERT INTO users (username, email, password, first_name, last_name, role) VALUES
('admin', 'admin@taskmanagement.com', '$2a$10$DowJonesIndexPassword', 'Admin', 'User', 'ADMIN'),
('john.doe', 'john.doe@company.com', '$2a$10$DowJonesIndexPassword', 'John', 'Doe', 'USER'),
('jane.smith', 'jane.smith@company.com', '$2a$10$DowJonesIndexPassword', 'Jane', 'Smith', 'MANAGER'),
('mike.johnson', 'mike.johnson@company.com', '$2a$10$DowJonesIndexPassword', 'Mike', 'Johnson', 'USER'),
('sarah.wilson', 'sarah.wilson@company.com', '$2a$10$DowJonesIndexPassword', 'Sarah', 'Wilson', 'USER');

-- Insert sample projects
INSERT INTO projects (name, description, status, start_date, end_date, created_by) VALUES
('Task Management System', 'Development of a comprehensive task management platform', 'ACTIVE', '2025-08-01', '2025-12-31', 1),
('Mobile App Development', 'Creating mobile applications for iOS and Android', 'ACTIVE', '2025-09-01', '2026-03-31', 1),
('Database Optimization', 'Improving database performance and scalability', 'ACTIVE', '2025-08-15', '2025-11-30', 1);

-- Insert sample tasks
INSERT INTO tasks (title, description, priority, status, assignee, due_date) VALUES
('Setup Development Environment', 'Configure React, Spring Boot, and MySQL development environment', 'HIGH', 'COMPLETED', 'John Doe', '2025-08-20'),
('Design Database Schema', 'Create comprehensive database schema for all entities', 'HIGH', 'IN_PROGRESS', 'Jane Smith', '2025-08-25'),
('Implement REST APIs', 'Develop RESTful APIs for all CRUD operations', 'MEDIUM', 'PENDING', 'Mike Johnson', '2025-08-30'),
('Create User Authentication', 'Implement JWT-based authentication system', 'HIGH', 'PENDING', 'Sarah Wilson', '2025-09-01'),
('Frontend Component Development', 'Build React components for task management', 'MEDIUM', 'IN_PROGRESS', 'John Doe', '2025-09-05'),
('API Integration', 'Integrate frontend with backend APIs', 'MEDIUM', 'PENDING', 'Jane Smith', '2025-09-10'),
('Testing and Quality Assurance', 'Comprehensive testing of all functionalities', 'HIGH', 'PENDING', 'Mike Johnson', '2025-09-15'),
('Deployment Configuration', 'Set up production deployment pipeline', 'MEDIUM', 'PENDING', 'Sarah Wilson', '2025-09-20'),
('Documentation', 'Create user and technical documentation', 'LOW', 'PENDING', 'John Doe', '2025-09-25'),
('Performance Optimization', 'Optimize application performance and loading times', 'MEDIUM', 'PENDING', 'Jane Smith', '2025-09-30');

-- Link tasks to projects
INSERT INTO project_tasks (project_id, task_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10);

-- Insert sample comments
INSERT INTO task_comments (task_id, user_id, comment) VALUES
(1, 2, 'Development environment has been successfully configured. All tools are working properly.'),
(2, 3, 'Database schema design is 80% complete. Need to finalize the indexing strategy.'),
(3, 4, 'Started working on the user management APIs. Expected completion by end of week.'),
(4, 5, 'Researching the best JWT implementation for Spring Boot. Will have a prototype ready soon.');

-- Create views for reporting
CREATE VIEW task_summary AS
SELECT 
    t.id,
    t.title,
    t.priority,
    t.status,
    t.assignee,
    t.due_date,
    t.created_at,
    DATEDIFF(t.due_date, CURDATE()) as days_until_due,
    CASE 
        WHEN t.due_date < CURDATE() AND t.status != 'COMPLETED' THEN 'OVERDUE'
        WHEN DATEDIFF(t.due_date, CURDATE()) <= 3 AND t.status != 'COMPLETED' THEN 'DUE_SOON'
        ELSE 'ON_TRACK'
    END as urgency_status
FROM tasks t;

CREATE VIEW project_progress AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    COUNT(pt.task_id) as total_tasks,
    COUNT(CASE WHEN t.status = 'COMPLETED' THEN 1 END) as completed_tasks,
    COUNT(CASE WHEN t.status = 'IN_PROGRESS' THEN 1 END) as in_progress_tasks,
    COUNT(CASE WHEN t.status = 'PENDING' THEN 1 END) as pending_tasks,
    ROUND(
        (COUNT(CASE WHEN t.status = 'COMPLETED' THEN 1 END) * 100.0 / COUNT(pt.task_id)), 2
    ) as completion_percentage
FROM projects p
LEFT JOIN project_tasks pt ON p.id = pt.project_id
LEFT JOIN tasks t ON pt.task_id = t.id
GROUP BY p.id, p.name;

-- Stored procedures for common operations
DELIMITER //

CREATE PROCEDURE GetTaskStatistics()
BEGIN
    SELECT 
        'total' as metric, COUNT(*) as count FROM tasks
    UNION ALL
    SELECT 
        'pending' as metric, COUNT(*) as count FROM tasks WHERE status = 'PENDING'
    UNION ALL
    SELECT 
        'in_progress' as metric, COUNT(*) as count FROM tasks WHERE status = 'IN_PROGRESS'
    UNION ALL
    SELECT 
        'completed' as metric, COUNT(*) as count FROM tasks WHERE status = 'COMPLETED'
    UNION ALL
    SELECT 
        'overdue' as metric, COUNT(*) as count 
    FROM tasks 
    WHERE due_date < CURDATE() AND status != 'COMPLETED';
END //

CREATE PROCEDURE GetUserTaskLoad()
BEGIN
    SELECT 
        assignee,
        COUNT(*) as total_tasks,
        COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_tasks,
        COUNT(CASE WHEN status = 'IN_PROGRESS' THEN 1 END) as in_progress_tasks,
        COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_tasks
    FROM tasks 
    WHERE assignee IS NOT NULL
    GROUP BY assignee
    ORDER BY total_tasks DESC;
END //

DELIMITER ;