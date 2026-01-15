class RemoveSolidQueueTables < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign keys first
    remove_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", if_exists: true
    remove_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", if_exists: true
    remove_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", if_exists: true
    remove_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", if_exists: true
    remove_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", if_exists: true
    remove_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", if_exists: true

    # Drop tables in reverse dependency order
    drop_table "solid_queue_blocked_executions", if_exists: true
    drop_table "solid_queue_claimed_executions", if_exists: true
    drop_table "solid_queue_failed_executions", if_exists: true
    drop_table "solid_queue_ready_executions", if_exists: true
    drop_table "solid_queue_recurring_executions", if_exists: true
    drop_table "solid_queue_scheduled_executions", if_exists: true
    drop_table "solid_queue_semaphores", if_exists: true
    drop_table "solid_queue_recurring_tasks", if_exists: true
    drop_table "solid_queue_processes", if_exists: true
    drop_table "solid_queue_pauses", if_exists: true
    drop_table "solid_queue_jobs", if_exists: true
  end

  def down
    # This migration cannot be reversed as we don't have the original table structure
    raise ActiveRecord::IrreversibleMigration
  end
end
