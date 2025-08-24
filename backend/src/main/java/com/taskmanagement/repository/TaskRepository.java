package com.taskmanagement.repository;

import com.taskmanagement.model.Task;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    
    List<Task> findByStatus(Task.Status status);
    
    List<Task> findByPriority(Task.Priority priority);
    
    List<Task> findByAssigneeContainingIgnoreCase(String assignee);
    
    List<Task> findByDueDateBefore(LocalDate date);
    
    List<Task> findByDueDateBetween(LocalDate startDate, LocalDate endDate);
    
    @Query("SELECT t FROM Task t WHERE t.title LIKE %:keyword% OR t.description LIKE %:keyword%")
    List<Task> findByTitleOrDescriptionContaining(@Param("keyword") String keyword);
    
    @Query("SELECT t FROM Task t WHERE " +
           "(:status IS NULL OR t.status = :status) AND " +
           "(:priority IS NULL OR t.priority = :priority) AND " +
           "(:assignee IS NULL OR t.assignee LIKE %:assignee%)")
    Page<Task> findTasksWithFilters(@Param("status") Task.Status status,
                                   @Param("priority") Task.Priority priority,
                                   @Param("assignee") String assignee,
                                   Pageable pageable);
    
    long countByStatus(Task.Status status);
}
